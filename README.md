# Food Mandalay

A Flutter-based food delivery application built for Mandalay, Myanmar.

Food Mandalay is a personal project focused on providing a modern food ordering experience with restaurant discovery, location-based features, online ordering, merchant communication, and push notifications.

## Features

- User authentication
- Restaurant and food browsing
- Food and restaurant search
- Location and map integration
- Cart management
- Checkout and order placement
- Order history and tracking
- Customer–merchant chat
- Food and product reviews
- Push notifications
- Multi-language support
- Responsive UI for mobile, tablet, and desktop

## Tech Stack

### Frontend

- Flutter
- Dart
- Riverpod
- Feature-based MVVM architecture

### Backend and Services

- Supabase
- PostgreSQL
- Firebase
- OneSignal
- Flutter Map

### Other Technologies

- REST APIs
- Supabase Realtime
- Firebase Services
- Push Notifications
- Location-based services

## Architecture

The project follows a feature-based MVVM architecture with Riverpod for state management.

```text
lib/
├── core/
├── features/
│   ├── auth/
│   ├── cart/
│   ├── category/
│   ├── checkout/
│   ├── explore/
│   ├── favourites/
│   ├── home/
│   ├── location/
│   ├── message/
│   ├── order_history/
│   ├── product_detail/
│   ├── profile/
│   ├── review/
│   └── search/
└── shared/