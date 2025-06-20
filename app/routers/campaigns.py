import os
import uuid
import shutil
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date

from app.database.database import get_db
from app.models.models import AdCampaign
from app.schemas.schemas import AdCampaign as AdCampaignSchema
from app.schemas.schemas import AdCampaignCreate

router = APIRouter(
    prefix="/campaigns",
    tags=["campaigns"],
)

# Define upload directory
UPLOAD_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "uploads")

# Ensure upload directory exists
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/", response_model=AdCampaignSchema)
async def create_campaign(
    name: str = Form(...),
    file_type: str = Form(...),
    content: Optional[str] = Form(None),
    guidelines: Optional[str] = Form(None),
    file: Optional[UploadFile] = File(None),
    file_url: Optional[str] = Form(None),
    db: Session = Depends(get_db)
):
    download_link = None
    video_path = None

    # Handle file upload or URL
    if file and file.filename:
        # Generate a unique filename
        file_extension = os.path.splitext(file.filename)[1]
        unique_filename = f"{uuid.uuid4()}{file_extension}"
        file_path = os.path.join(UPLOAD_DIR, unique_filename)
        
        # Save file to disk
        try:
            with open(file_path, "wb") as buffer:
                shutil.copyfileobj(file.file, buffer)
            
            # Set the proper path values based on file type
            if file_type.lower() in ["video", "mp4", "mov", "avi"]:
                video_path = file_path
            
            download_link = f"/downloads/{unique_filename}"
                
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Could not save file: {str(e)}")
    elif file_url:
        # If a URL is provided, store it directly
        download_link = file_url
    else:
        raise HTTPException(status_code=400, detail="Either file or file_url must be provided")

    # Create new ad campaign
    db_campaign = AdCampaign(
        name=name,
        file_type=file_type,
        content=content,
        guidelines=guidelines,
        video_path=video_path,
        download_link=download_link,
        file_url=file_url,
        uploaded_date=date.today(),
        status="In Progress",
    )

    db.add(db_campaign)
    db.commit()
    db.refresh(db_campaign)
    return db_campaign

@router.get("/", response_model=List[AdCampaignSchema])
def get_all_campaigns(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    campaigns = db.query(AdCampaign).offset(skip).limit(limit).all()
    return campaigns

@router.get("/{campaign_id}", response_model=AdCampaignSchema)
def get_campaign(campaign_id: int, db: Session = Depends(get_db)):
    campaign = db.query(AdCampaign).filter(AdCampaign.id == campaign_id).first()
    if campaign is None:
        raise HTTPException(status_code=404, detail="Campaign not found")
    return campaign

@router.put("/{campaign_id}", response_model=AdCampaignSchema)
def update_campaign(
    campaign_id: int, 
    campaign: AdCampaignCreate, 
    db: Session = Depends(get_db)
):
    db_campaign = db.query(AdCampaign).filter(AdCampaign.id == campaign_id).first()
    if db_campaign is None:
        raise HTTPException(status_code=404, detail="Campaign not found")
    
    for key, value in campaign.model_dump().items():
        setattr(db_campaign, key, value)
    
    db.commit()
    db.refresh(db_campaign)
    return db_campaign

@router.delete("/{campaign_id}")
def delete_campaign(campaign_id: int, db: Session = Depends(get_db)):
    campaign = db.query(AdCampaign).filter(AdCampaign.id == campaign_id).first()
    if campaign is None:
        raise HTTPException(status_code=404, detail="Campaign not found")
    
    db.delete(campaign)
    db.commit()
    return {"message": "Campaign deleted successfully"}
