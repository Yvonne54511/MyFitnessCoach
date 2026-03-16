Program.cs
```csharp
 builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
        .AddCookie(options =>
        {
            // 1. 當 [Authorize] 判定未登入時，自動導向這裡 (401 Unauthorized)
            options.LoginPath = "/Account/Login";
   
            // 2. 當權限不足時，自動導向這裡 (403 Forbidden)
            options.AccessDeniedPath = "/Account/AccessDenied";
        });
  ```