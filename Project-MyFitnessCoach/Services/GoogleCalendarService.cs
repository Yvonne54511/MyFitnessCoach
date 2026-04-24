using Google.Apis.Auth.OAuth2;
using Google.Apis.Auth.OAuth2.Flows;
using Google.Apis.Auth.OAuth2.Responses;
using Google.Apis.Calendar.v3;
using Google.Apis.Calendar.v3.Data;
using Google.Apis.Services;
using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.EfModels;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Services
{
    public class GoogleCalendarService
    {
        private readonly IConfiguration _config;
        private readonly MyFitnessCoachDbContext _db;
        private readonly ILogger<GoogleCalendarService> _logger;

        public GoogleCalendarService(IConfiguration config, MyFitnessCoachDbContext db, ILogger<GoogleCalendarService> logger)
        {
            _config = config;
            _db = db;
            _logger = logger;
        }

        public async Task<string> AddEventAsync(int userId, string summary, string description, DateTime startTime, DateTime endTime)
        {
            var clientId = _config["Google:ClientId"];
            var clientSecret = _config["Google:ClientSecret"];
            
            var loginInfo = await _db.UserExternalLogins
                .FirstOrDefaultAsync(l => l.UserId == userId && l.LoginProvider == "GoogleCalendar");

            if (loginInfo == null || string.IsNullOrEmpty(loginInfo.ProviderKey)) return null;

            try 
            {
                var tokenResponse = new TokenResponse { RefreshToken = loginInfo.ProviderKey };
                var flow = new GoogleAuthorizationCodeFlow(new GoogleAuthorizationCodeFlow.Initializer
                {
                    ClientSecrets = new ClientSecrets { ClientId = clientId, ClientSecret = clientSecret },
                    Scopes = new[] { CalendarService.Scope.CalendarEvents }
                });

                var credential = new UserCredential(flow, userId.ToString(), tokenResponse);
                var service = new CalendarService(new BaseClientService.Initializer()
                {
                    HttpClientInitializer = credential,
                    ApplicationName = "MyFitnessCoach",
                });

                var newEvent = new Event()
                {
                    Summary = summary,
                    Description = description,
                    Start = new EventDateTime() { DateTimeDateTimeOffset = startTime, TimeZone = "Asia/Taipei" },
                    End = new EventDateTime() { DateTimeDateTimeOffset = endTime, TimeZone = "Asia/Taipei" }
                };

                var createdEvent = await service.Events.Insert(newEvent, "primary").ExecuteAsync();
                return createdEvent.Id;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Google AddEvent Error");
                return null;
            }
        }

        public async Task DeleteEventAsync(int userId, string eventId)
        {
            _logger.LogInformation("[Google Sync] 準備刪除日曆事件: UserId={UserId}, EventId={EventId}", userId, eventId);

            if (string.IsNullOrEmpty(eventId)) 
            {
                _logger.LogWarning("[Google Sync] EventId 為空，跳過刪除");
                return;
            }

            var clientId = _config["Google:ClientId"];
            var clientSecret = _config["Google:ClientSecret"];

            if (string.IsNullOrEmpty(clientId))
            {
                _logger.LogError("[Google Sync] 缺失 Google:ClientId 設定，請檢查 appsettings.json 或 User Secrets");
                return;
            }
            
            var loginInfo = await _db.UserExternalLogins
                .FirstOrDefaultAsync(l => l.UserId == userId && l.LoginProvider == "GoogleCalendar");

            if (loginInfo == null)
            {
                _logger.LogWarning("[Google Sync] 找不到 UserId={UserId} 的 GoogleCalendar 授權紀錄 (UserExternalLogins)", userId);
                return;
            }

            try 
            {
                var tokenResponse = new TokenResponse { RefreshToken = loginInfo.ProviderKey };
                var flow = new GoogleAuthorizationCodeFlow(new GoogleAuthorizationCodeFlow.Initializer
                {
                    ClientSecrets = new ClientSecrets { ClientId = clientId, ClientSecret = clientSecret },
                    Scopes = new[] { CalendarService.Scope.CalendarEvents }
                });

                var credential = new UserCredential(flow, userId.ToString(), tokenResponse);
                
                var service = new CalendarService(new BaseClientService.Initializer()
                {
                    HttpClientInitializer = credential,
                    ApplicationName = "MyFitnessCoach",
                });

                await service.Events.Delete("primary", eventId).ExecuteAsync();
                _logger.LogInformation("[Google Sync] 成功從 Google 日曆刪除事件 (EventId: {EventId})", eventId);
            }
            catch (Google.GoogleApiException gEx) when (gEx.HttpStatusCode == System.Net.HttpStatusCode.NotFound)
            {
                _logger.LogWarning("[Google Sync] Google 伺服器回報找不到該事件，可能已被手動刪除 (EventId: {EventId})", eventId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[Google Sync] 刪除過程中發生異常: {Message}", ex.Message);
            }
        }
    }
}
