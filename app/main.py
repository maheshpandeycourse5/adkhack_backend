import os
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.database.database import engine, Base
from app.routers import campaigns

# Create the database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="AdHack API",
    description="API for AdHack campaign management",
    version="1.0.0",
)

# CORS middleware configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust this in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static files for downloads
uploads_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "uploads")
os.makedirs(uploads_dir, exist_ok=True)
app.mount("/downloads", StaticFiles(directory=uploads_dir), name="downloads")

# Include routers
app.include_router(campaigns.router)

@app.get("/")
def read_root():
    return {"message": "Welcome to the AdHack API"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
