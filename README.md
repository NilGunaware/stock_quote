# Stock Quote App

A comprehensive Flutter application for tracking stock quotes in real-time, built with MVVM architecture and Provider state management.

## Features

- **Real-time Stock Quotes**: Get up-to-date stock information including price, change, and percentage change
- **Search Functionality**: Search for stocks by symbol or company name
- **Watchlist**: Add/remove stocks to your watchlist for quick access
- **Sector-based Grouping**: View stocks grouped by industry sectors
- **Detailed Stock Information**: Access comprehensive stock details including:
  - Company information
  - Price charts
  - Market cap
  - P/E ratio
  - Sector and industry classification
- **Offline Support**: Cache stock data for offline viewing
- **Auto-refresh**: Automatic updates of stock prices
- **Responsive Design**: Works seamlessly across different screen sizes

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data classes representing stock information
- **Views**: UI components and screens
- **ViewModels**: Business logic and state management
- **Services**: API and storage handling

## Dependencies

- `provider`: State management
- `http` & `dio`: API communication
- `syncfusion_flutter_charts`: Stock price visualization
- `shared_preferences`: Local storage
- `intl`: Formatting
- `flutter_dotenv`: Environment configuration

## Setup

1. Clone the repository
2. Create a `.env` file in the root directory with your API keys:
   ```
   IEX_CLOUD_API_KEY=your_api_key_here
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── models/
│   └── stock.dart
├── screens/
│   ├── home_screen.dart
│   └── stock_detail_screen.dart
├── services/
│   ├── stock_api_service.dart
│   └── storage_service.dart
├── viewmodels/
│   └── stock_view_model.dart
├── widgets/
│   └── stock_card.dart
└── main.dart
```

## Testing

The app includes unit tests for core functionalities:
- API service tests
- ViewModel tests
- Widget tests

Run tests using:
```bash
flutter test
```

## Performance Considerations

- Efficient data caching for offline access
- Optimized API calls with debouncing for search
- Lazy loading of sector-based stock data
- Background refresh of watchlist stocks

## Error Handling

The app implements comprehensive error handling for:
- Network issues
- Invalid API responses
- Local storage failures
- Invalid user input

## Future Improvements

- Add more technical indicators
- Implement push notifications for price alerts
- Add portfolio tracking
- Enhance charting capabilities
- Add more fundamental data

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
