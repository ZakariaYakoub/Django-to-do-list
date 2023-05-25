# Use an official Python runtime as the base image
FROM python:3.12.0b1-alpine3.18


# Set the working directory in the container
WORKDIR /app


# Install dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Django project code into the container
COPY src/project /app/


# Expose the port that Django runs on
EXPOSE 8000

# Run the Django development server
CMD ["python", "manage.py", "runserver"]
