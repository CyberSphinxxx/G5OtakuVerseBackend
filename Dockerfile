# Use official PHP image with necessary extensions
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    zip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    sqlite3 \
    libsqlite3-dev \
    nodejs \
    npm \
    && docker-php-ext-install pdo pdo_mysql pdo_sqlite mbstring exif pcntl bcmath gd zip \
    && apt-get clean

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy application files
COPY . .

# Install PHP dependencies (avoid --no-dev if you’re in a build environment)
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Set permissions for Laravel directories
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Build Vite frontend (optional, if you're using Vite)
RUN npm install && npm run build

# Ensure SQLite database exists (optional, only if using SQLite)
RUN mkdir -p /var/www/database && touch /var/www/database/database.sqlite

# Expose Laravel server port
EXPOSE 8000

# Run migrations and start the Laravel dev server
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000
