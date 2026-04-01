using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Project_MyFitnessCoach.Services
{
	public interface IPayPalService
	{
		Task<string?> GetAccessTokenAsync();
		Task<(bool Success, string? ErrorMessage)> CreatePayoutAsync(string receiverEmail, decimal amount, string note);
	}

	public class PayPalService : IPayPalService
	{
		private readonly IHttpClientFactory _httpClientFactory;
		private readonly string _clientId;
		private readonly string _secret;
		private readonly string _url;

		public PayPalService(IConfiguration configuration, IHttpClientFactory httpClientFactory)
		{
			_clientId = configuration["PayPalSettings:ClientId"] ?? "";
			_secret = configuration["PayPalSettings:Secret"] ?? "";
			_url = configuration["PayPalSettings:Url"] ?? "";
			_httpClientFactory = httpClientFactory;
		}

		public async Task<string?> GetAccessTokenAsync()
		{
			Console.WriteLine("PayPal: Requesting Access Token...");
			var client = _httpClientFactory.CreateClient();
			var authString = Convert.ToBase64String(Encoding.UTF8.GetBytes($"{_clientId}:{_secret}"));
			client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", authString);

			var requestData = new List<KeyValuePair<string, string>>
			{
				new KeyValuePair<string, string>("grant_type", "client_credentials")
			};

			var response = await client.PostAsync($"{_url}/v1/oauth2/token", new FormUrlEncodedContent(requestData));

			if (response.IsSuccessStatusCode)
			{
				var content = await response.Content.ReadAsStringAsync();
				var tokenResponse = JsonSerializer.Deserialize<PayPalTokenResponse>(content);
				Console.WriteLine("PayPal: Access Token acquired successfully.");
				return tokenResponse?.AccessToken;
			}

			var errorToken = await response.Content.ReadAsStringAsync();
			Console.WriteLine($"PayPal Token Error ({response.StatusCode}): {errorToken}");
			return null;
		}

		public async Task<(bool Success, string? ErrorMessage)> CreatePayoutAsync(string receiverEmail, decimal amount, string note)
		{
			Console.WriteLine($"PayPal: Starting Payout to {receiverEmail} for {amount} USD");
			var token = await GetAccessTokenAsync();
			if (string.IsNullOrEmpty(token))
			{
				Console.WriteLine("PayPal: Payout failed because Token is null or empty.");
				return (false, "無法取得 PayPal Access Token，請檢查 ClientId 與 Secret。");
			}

			var client = _httpClientFactory.CreateClient();
			client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

			var payoutRequest = new
			{
				sender_batch_header = new
				{
					sender_batch_id = $"Batch_{Guid.NewGuid()}",
					email_subject = "You have a payment",
					email_message = "You have received a payout! Thanks for using our service!"
				},
				items = new[]
				{
					new
					{
						recipient_type = "EMAIL",
						amount = new
						{
							value = amount.ToString("F2", System.Globalization.CultureInfo.InvariantCulture),
							currency = "USD" 
						},
						note = note,
						sender_item_id = $"Item_{Guid.NewGuid()}",
						receiver = receiverEmail
					}
				}
			};

			var json = JsonSerializer.Serialize(payoutRequest);
			var content = new StringContent(json, Encoding.UTF8, "application/json");

			var response = await client.PostAsync($"{_url}/v1/payments/payouts", content);
			var responseContent = await response.Content.ReadAsStringAsync();

			if (!response.IsSuccessStatusCode)
			{
				System.Diagnostics.Debug.WriteLine($"PayPal Payout Error: {responseContent}");
				Console.WriteLine($"PayPal Payout Error: {responseContent}");
				return (false, $"PayPal Payout Error: {responseContent}");
			}
			else
			{
				Console.WriteLine("PayPal: Payout request sent successfully.");
				return (true, null);
			}
		}

		private class PayPalTokenResponse
		{
			[JsonPropertyName("access_token")]
			public string AccessToken { get; set; } = "";
		}
	}
}
