// Data source adapters
// Each adapter implements the DataSourceAdapter trait for a specific data source

mod google_search;
mod wikipedia;
mod weather_api;
mod openweather;
mod news_api;

pub use google_search::GoogleSearchAdapter;
pub use wikipedia::WikipediaAdapter;
pub use weather_api::WeatherApiAdapter;
pub use openweather::OpenWeatherAdapter;
pub use news_api::NewsApiAdapter;

// TODO: Implement additional adapters
// Priority order for Phase 2 (50 adapters):
//
// Web Search (5):
// - BingSearchAdapter
// - DuckDuckGoAdapter
// - BraveSearchAdapter
// - YandexSearchAdapter
// - BaiduSearchAdapter
//
// Knowledge (5):
// - WikidataAdapter
// - DBpediaAdapter
// - WolframAlphaAdapter
// - StackOverflowAdapter
// - QuoraAdapter
//
// Social Media (5):
// - TwitterAdapter (X)
// - RedditAdapter
// - LinkedInAdapter
// - FacebookAdapter
// - InstagramAdapter
//
// Media (5):
// - YouTubeAdapter
// - VimeoAdapter
// - SoundCloudAdapter
// - SpotifyAdapter
// - TwitchAdapter
//
// News (5):
// - BBCNewsAdapter
// - CNNAdapter
// - ReutersAdapter
// - APNewsAdapter
// - NYTimesAdapter
//
// Weather (3):
// - WeatherGovAdapter
// - AccuWeatherAdapter
// - DarkSkyAdapter
//
// Maps & Location (3):
// - GoogleMapsAdapter
// - OpenStreetMapAdapter
// - MapboxAdapter
//
// Finance (3):
// - YahooFinanceAdapter
// - AlphaVantageAdapter
// - CoinGeckoAdapter
//
// Shopping (3):
// - AmazonAdapter
// - eBayAdapter
// - AliExpressAdapter
//
// Personal Data (5):
// - GmailAdapter
// - GoogleDriveAdapter
// - DropboxAdapter
// - OneDriveAdapter
// - iCloudAdapter
//
// Enterprise (5):
// - SlackAdapter
// - NotionAdapter
// - JiraAdapter
// - GitHubAdapter
// - ConfluenceAdapter
//
// Academic (3):
// - GoogleScholarAdapter
// - ArXivAdapter
// - PubMedAdapter
//
// Total Phase 2: 50 adapters
// Total Phase 3: 200 adapters
// Total Phase 4: 500 adapters
// Total Phase 5: 1000+ adapters
