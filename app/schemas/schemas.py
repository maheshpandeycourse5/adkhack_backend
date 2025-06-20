from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import date

class AdCampaignBase(BaseModel):
    name: str
    file_type: str
    content: Optional[str] = None
    guidelines: Optional[str] = None

class AdCampaignCreate(AdCampaignBase):
    pass

class AdCampaign(AdCampaignBase):
    id: int
    uploaded_date: date
    status: str
    score: Optional[str] = None
    video_path: Optional[str] = None
    download_link: Optional[str] = None
    approval_date: Optional[date] = None
    conflicts: List[str] = []
    suggestions: List[str] = []
    file_url: Optional[str] = None

    class Config:
        orm_mode = True
        from_attributes = True
