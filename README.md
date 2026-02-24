# Sales Dashboard Application

A simple Flask-based sales dashboard that displays revenue metrics, monthly trends, and top products.

## Features
- Real-time sales metrics (Total Revenue, Units Sold, Avg Order Value)
- Monthly revenue trend chart
- Top products bar chart
- Responsive design
- Health check endpoint

## Local Development

### Run without Docker
```bash
pip install -r requirements.txt
python app.py
```
Visit: http://localhost:5000

### Run with Docker
```bash
# Build the image
docker build -t sales-dashboard .

# Run the container
docker run -p 5000:5000 sales-dashboard
```
Visit: http://localhost:5000

## API Endpoints
- `/` - Main dashboard
- `/health` - Health check endpoint (returns JSON status)

## Technologies Used
- Flask (Python web framework)
- Chart.js (for data visualization)
- Docker (containerization)
