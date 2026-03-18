using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Project_MyFitnessCoach.Models.EfModels;
using System.Linq;
using System.Threading.Tasks;

namespace Project_MyFitnessCoach.Controllers
{
    public class PointsRecordsController : Controller
    {
        private readonly MyFitnessCoachDbContext _context;

        public PointsRecordsController(MyFitnessCoachDbContext context)
        {
            _context = context;
        }

        // 列出所有點數進出紀錄
        public async Task<IActionResult> Index(string searchString, string category, int? memberId, int? recordId)
        {
            ViewBag.SearchString = searchString;
            ViewBag.Category = category;
            ViewBag.RecordId = recordId;

            var query = _context.PointsRecordDetails
                .Include(r => r.UserWallet)
                .ThenInclude(w => w.Member)
                .ThenInclude(m => m.User)
                .AsQueryable();

            // 若有輸入紀錄 ID，優先以 ID 搜尋並直接返回結果
            if (recordId.HasValue)
            {
                query = query.Where(r => r.Id == recordId.Value);
            }
            else
            {
                // 否則才進行其他複合篩選
                if (memberId.HasValue)
                {
                    query = query.Where(r => r.UserWallet.MemberId == memberId.Value);
                    var member = await _context.Members.Include(m => m.User).FirstOrDefaultAsync(m => m.Id == memberId.Value);
                    ViewBag.MemberName = member?.User?.UserName;
                }

                if (!string.IsNullOrEmpty(searchString))
                {
                    query = query.Where(r => r.UserWallet.Member.User.UserName.Contains(searchString));
                }

                if (!string.IsNullOrEmpty(category))
                {
                    query = query.Where(r => r.MerchandiseCategory == category);
                }
            }

            var records = await query.OrderByDescending(r => r.CreateAt).ToListAsync();
            
            return View(records);
        }
    }
}
