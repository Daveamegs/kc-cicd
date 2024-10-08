# Python Docker Image
FROM python:3

# Set the working directory
WORKDIR /app

# Copy contents from the app directory into the container at /app
COPY app/ /app

# Install any needed packages specified in requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

# Expose port 8000
EXPOSE 8000

# Run app.py when the container launches
CMD ["python3", "app.py"]
