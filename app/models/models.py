from sqlalchemy import Column, Integer, String, Date, Text, ARRAY
from sqlalchemy.sql import func

from app.database.database import Base

class AdCampaign(Base):
    __tablename__ = "ad_campaigns"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    uploaded_date = Column(Date, server_default=func.current_date(), nullable=False)
    status = Column(String(50), default="Pending", nullable=False)
    score = Column(String(10))
    video_path = Column(Text)
    content = Column(Text)
    guidelines = Column(Text)
    file_type = Column(String(50), nullable=False)
    download_link = Column(Text)
    approval_date = Column(Date)
    conflicts = Column(ARRAY(Text), default=[])
    suggestions = Column(ARRAY(Text), default=[])
    file_url = Column(Text)
