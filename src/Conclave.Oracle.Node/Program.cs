using Conclave.Oracle;
using Conclave.Oracle.Node.Extensions;
using Conclave.Oracle.Node.Services;

var builder = WebApplication.CreateBuilder(args);
// Add services to the container.
builder.Services.AddSingleton<FakeInteropService>();
builder.Services.AddHttpClient();
builder.Services.AddControllers();
builder.Services.AddBrowserService();
builder.Services.AddHostedService<OracleWorker>();
var app = builder.Build();

app.UseStaticFiles();
app.MapControllers();
app.Run();