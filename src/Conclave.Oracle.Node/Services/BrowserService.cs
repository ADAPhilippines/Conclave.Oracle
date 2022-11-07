
using System.Net;
using Microsoft.AspNetCore.Hosting.Server;
using Microsoft.AspNetCore.Hosting.Server.Features;
using PuppeteerSharp;

namespace Conclave.Oracle.Node.Service;

public class BrowserService : IAsyncDisposable
{
    #region Public Properties
    public string? BaseUrl { get; set; }
    public bool IsInitialized { get; private set; }
    #endregion

    #region Private Properties
    private IBrowser? Browser { get; set; }
    private IPage? Page { get; set; }
    private BrowserFetcher? BrowserFetcher { get; set; }
    private readonly IServer _server;
    private readonly HttpClient _httpClient;
    private readonly ILogger<BrowserService> _logger;
    private int LastPercentRecorded { get; set; }
    #endregion

    public BrowserService(IServer server, HttpClient httpClient, ILogger<BrowserService> logger)
    {
        _server = server;
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task InitializeAsync()
    {
        _logger.LogInformation("Downloading Latest Chromium...");
        BrowserFetcher = new();
        BrowserFetcher.DownloadProgressChanged += OnFetcherDownloadProgressChanged;
        await BrowserFetcher.DownloadAsync(BrowserFetcher.DefaultChromiumRevision);
        _logger.LogInformation("Launching Browser");
        Browser = await Puppeteer.LaunchAsync(new()
        {
            Headless = false
        });
        _logger.LogInformation("Browser launched succesfully.");
        Page = await Browser.NewPageAsync();
        while (string.IsNullOrEmpty(BaseUrl = GetServerBaseUrl())) await Task.Delay(1000);

        Uri baseUrl = new(BaseUrl);
        await Page.GoToAsync(new Uri(baseUrl, "index.html").ToString());
        _logger.LogInformation($"Browser Initialized 🚀🚀🚀");
        IsInitialized = true;
    }

    private void OnFetcherDownloadProgressChanged(object sender, DownloadProgressChangedEventArgs e)
    {
        if (LastPercentRecorded != e.ProgressPercentage)
        {
            LastPercentRecorded = e.ProgressPercentage;
            _logger.LogInformation($"Browser Downloading: {e.ProgressPercentage}%");
        }
    }

    public async ValueTask DisposeAsync()
    {
        if (Browser is not null)
            await Browser.CloseAsync();

        if (BrowserFetcher is not null)
            BrowserFetcher.DownloadProgressChanged -= OnFetcherDownloadProgressChanged;
    }

    private string? GetServerBaseUrl()
    {
        var addressFeature = _server.Features.Get<IServerAddressesFeature>();
        return addressFeature?.Addresses.FirstOrDefault();
    }
}