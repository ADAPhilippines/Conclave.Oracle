using Conclave.Oracle.Node.Services;
using Microsoft.AspNetCore.Mvc;

namespace Conclave.Oracle.Node.Controllers;

[ApiController]
[Route("[controller]")]
public class TestController : ControllerBase
{
    private readonly ILogger<TestController> _logger;
    private readonly BrowserService _browserService;

    public TestController(ILogger<TestController> logger, BrowserService browserService)
    {
        _logger = logger;
        _browserService = browserService;
    }

    [HttpGet(Name = "GetWeatherForecast")]
    public async Task<ActionResult> Get()
    {
        await _browserService.InitializeAsync();
        return Ok();
    }
}
