using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace Project_MyFitnessCoach.Models.EfModels;

public partial class MyFitnessCoachDbContext : DbContext
{
    public MyFitnessCoachDbContext(DbContextOptions<MyFitnessCoachDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<BodyRecord> BodyRecords { get; set; }

    public virtual DbSet<Department> Departments { get; set; }

    public virtual DbSet<Employee> Employees { get; set; }

    public virtual DbSet<Food> Foods { get; set; }

    public virtual DbSet<FoodCategory> FoodCategories { get; set; }

    public virtual DbSet<FoodRecord> FoodRecords { get; set; }

    public virtual DbSet<Function> Functions { get; set; }

    public virtual DbSet<Holiday> Holidays { get; set; }

    public virtual DbSet<Instructor> Instructors { get; set; }

    public virtual DbSet<InstructorWallet> InstructorWallets { get; set; }

    public virtual DbSet<InstructorWalletDetail> InstructorWalletDetails { get; set; }

    public virtual DbSet<KeyWord> KeyWords { get; set; }

    public virtual DbSet<LeaveApprovalDelegation> LeaveApprovalDelegations { get; set; }

    public virtual DbSet<LeaveAttachment> LeaveAttachments { get; set; }

    public virtual DbSet<LeaveBalance> LeaveBalances { get; set; }

    public virtual DbSet<LeaveBalanceHistory> LeaveBalanceHistories { get; set; }

    public virtual DbSet<LeaveRequest> LeaveRequests { get; set; }

    public virtual DbSet<LeaveType> LeaveTypes { get; set; }

    public virtual DbSet<Member> Members { get; set; }

    public virtual DbSet<MemberViolation> MemberViolations { get; set; }

    public virtual DbSet<Notification> Notifications { get; set; }

    public virtual DbSet<Nutrient> Nutrients { get; set; }

    public virtual DbSet<PointOrder> PointOrders { get; set; }

    public virtual DbSet<PointsRecordDetail> PointsRecordDetails { get; set; }

    public virtual DbSet<Product> Products { get; set; }

    public virtual DbSet<ProductCategory> ProductCategories { get; set; }

    public virtual DbSet<ProductOrder> ProductOrders { get; set; }

    public virtual DbSet<ProductOrderDetail> ProductOrderDetails { get; set; }

    public virtual DbSet<ReserveOrder> ReserveOrders { get; set; }

    public virtual DbSet<Review> Reviews { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<RoleFunction> RoleFunctions { get; set; }

    public virtual DbSet<Shift> Shifts { get; set; }

    public virtual DbSet<TopUpPlan> TopUpPlans { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<UserExternalLogin> UserExternalLogins { get; set; }

    public virtual DbSet<UserRole> UserRoles { get; set; }

    public virtual DbSet<UserWallet> UserWallets { get; set; }

    public virtual DbSet<VwEmployeeDeptInfo> VwEmployeeDeptInfos { get; set; }

    public virtual DbSet<VwRoleFunction> VwRoleFunctions { get; set; }

    public virtual DbSet<VwUserMemberFoodRecord> VwUserMemberFoodRecords { get; set; }

    public virtual DbSet<VwUserRoleFunction> VwUserRoleFunctions { get; set; }

    public virtual DbSet<VwUserRoleFunction1> VwUserRoleFunctions1 { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<BodyRecord>(entity =>
        {
            entity.Property(e => e.BodyFat).HasColumnType("decimal(4, 1)");
            entity.Property(e => e.CreateAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(getdate())");
            entity.Property(e => e.ImageUrl).HasMaxLength(300);
            entity.Property(e => e.Note).HasMaxLength(200);
            entity.Property(e => e.SkeletalMuscle).HasColumnType("decimal(4, 1)");
            entity.Property(e => e.WaistCircumference).HasColumnType("decimal(5, 1)");

            entity.HasOne(d => d.Member).WithMany(p => p.BodyRecords)
                .HasForeignKey(d => d.MemberId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_BodyRecords_Members");
        });

        modelBuilder.Entity<Department>(entity =>
        {
            entity.Property(e => e.Name).HasMaxLength(50);

            entity.HasOne(d => d.Manager).WithMany(p => p.Departments)
                .HasForeignKey(d => d.ManagerId)
                .HasConstraintName("FK_Dept_Manager");
        });

        modelBuilder.Entity<Employee>(entity =>
        {
            entity.HasIndex(e => e.UserId, "UQ_Employees_UserId").IsUnique();

            entity.Property(e => e.IsActive).HasDefaultValue(true);

            entity.HasOne(d => d.Department).WithMany(p => p.Employees)
                .HasForeignKey(d => d.DepartmentId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Employees_Dept");

            entity.HasOne(d => d.Manager).WithMany(p => p.InverseManager)
                .HasForeignKey(d => d.ManagerId)
                .HasConstraintName("FK_Employees_Manager");

            entity.HasOne(d => d.User).WithOne(p => p.Employee)
                .HasForeignKey<Employee>(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Employees_Users");

            entity.HasOne(d => d.WorkDelegate).WithMany(p => p.InverseWorkDelegate)
                .HasForeignKey(d => d.WorkDelegateId)
                .HasConstraintName("FK_Employees_WorkDel");
        });

        modelBuilder.Entity<Food>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Foods__3214EC07C7F2B043");

            entity.Property(e => e.FoodName).HasMaxLength(50);

            entity.HasOne(d => d.Category).WithMany(p => p.Foods)
                .HasForeignKey(d => d.CategoryId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Foods_FoodCategories");
        });

        modelBuilder.Entity<FoodCategory>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__FoodCate__3214EC07E329DDA5");

            entity.Property(e => e.CategoryName).HasMaxLength(50);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
        });

        modelBuilder.Entity<FoodRecord>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__FoodReco__3214EC07C1D3915B");

            entity.Property(e => e.EatDt)
                .HasPrecision(0)
                .HasDefaultValueSql("(getdate())")
                .HasColumnName("EatDT");
            entity.Property(e => e.MealType).HasMaxLength(20);
            entity.Property(e => e.Measure).HasMaxLength(20);

            entity.HasOne(d => d.Food).WithMany(p => p.FoodRecords)
                .HasForeignKey(d => d.FoodId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_FoodRecords_Foods");

            entity.HasOne(d => d.Member).WithMany(p => p.FoodRecords)
                .HasForeignKey(d => d.MemberId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_FoodRecords_Members");
        });

        modelBuilder.Entity<Function>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Function__3214EC0748923672");

            entity.Property(e => e.ApiPath)
                .HasMaxLength(255)
                .HasColumnName("Api_path");
            entity.Property(e => e.FunctionName).HasMaxLength(50);
        });

        modelBuilder.Entity<Holiday>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Holidays__3214EC074CA14230");

            entity.HasIndex(e => e.HolidayDate, "IX_Holidays_Date").IsUnique();

            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.Name).HasMaxLength(50);
        });

        modelBuilder.Entity<Instructor>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Instruct__3214EC07E9E33007");

            entity.Property(e => e.CancelCount).HasDefaultValue(1);
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.ImageUrl).HasMaxLength(300);
            entity.Property(e => e.IsActive).HasDefaultValue(true);

            entity.HasOne(d => d.User).WithMany(p => p.Instructors)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Instructors_Users");
        });

        modelBuilder.Entity<InstructorWallet>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Instruct__3214EC071D4BE08F");

            entity.Property(e => e.CurrentBalance).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.LastUpdated).HasPrecision(0);

            entity.HasOne(d => d.Instructor).WithMany(p => p.InstructorWallets)
                .HasForeignKey(d => d.InstructorId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_InstructorWallets_Instructors");
        });

        modelBuilder.Entity<InstructorWalletDetail>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Instruct__3214EC070CBC4F37");

            entity.Property(e => e.Category).HasMaxLength(50);
            entity.Property(e => e.CreatedAt).HasPrecision(0);
            entity.Property(e => e.SalaryDate).HasMaxLength(10);
            entity.Property(e => e.TotalAmount).HasColumnType("decimal(10, 2)");

            entity.HasOne(d => d.InstructorWallet).WithMany(p => p.InstructorWalletDetails)
                .HasForeignKey(d => d.InstructorWalletId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_InstructorWalletDetails_InstructorWallets");
        });

        modelBuilder.Entity<KeyWord>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__KeyWords__3214EC07A37FE1A5");

            entity.Property(e => e.Word).HasMaxLength(50);
        });

        modelBuilder.Entity<LeaveApprovalDelegation>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__LeaveApp__3214EC072758A1AC");

            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.IsActive).HasDefaultValue(true);

            entity.HasOne(d => d.DelegateEmployee).WithMany(p => p.LeaveApprovalDelegationDelegateEmployees)
                .HasForeignKey(d => d.DelegateEmployeeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ApprDel_Delegate");

            entity.HasOne(d => d.LeaveRequest).WithMany(p => p.LeaveApprovalDelegations)
                .HasForeignKey(d => d.LeaveRequestId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ApprDel_LeaveReq");

            entity.HasOne(d => d.ManagerEmployee).WithMany(p => p.LeaveApprovalDelegationManagerEmployees)
                .HasForeignKey(d => d.ManagerEmployeeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ApprDel_Manager");
        });

        modelBuilder.Entity<LeaveAttachment>(entity =>
        {
            entity.Property(e => e.FileName).HasMaxLength(200);
            entity.Property(e => e.FileUrl).HasMaxLength(500);
            entity.Property(e => e.UploadedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(getdate())");

            entity.HasOne(d => d.Request).WithMany(p => p.LeaveAttachments)
                .HasForeignKey(d => d.RequestId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Attach_Request");
        });

        modelBuilder.Entity<LeaveBalance>(entity =>
        {
            entity.HasIndex(e => new { e.EmployeeId, e.LeaveTypeId, e.Year }, "UQ_LeaveBalances_Key").IsUnique();

            entity.Property(e => e.RemainingDays)
                .HasComputedColumnSql("([TotalDays]-[UsedDays])", true)
                .HasColumnType("decimal(19, 2)");
            entity.Property(e => e.TotalDays).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.UsedDays)
                .HasDefaultValue(0m)
                .HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.Employee).WithMany(p => p.LeaveBalances)
                .HasForeignKey(d => d.EmployeeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Balance_Employee");

            entity.HasOne(d => d.LeaveType).WithMany(p => p.LeaveBalances)
                .HasForeignKey(d => d.LeaveTypeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Balance_LeaveType");
        });

        modelBuilder.Entity<LeaveBalanceHistory>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__LeaveBal__3214EC07DFCECC8C");

            entity.Property(e => e.ChangeDays).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.ChangeType).HasMaxLength(20);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.NewTotalDays).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.NewUsedDays).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.OldTotalDays).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.OldUsedDays).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.Reason).HasMaxLength(300);

            entity.HasOne(d => d.LeaveBalance).WithMany(p => p.LeaveBalanceHistories)
                .HasForeignKey(d => d.LeaveBalanceId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_LeaveBalanceHistories_LeaveBalance");

            entity.HasOne(d => d.Operator).WithMany(p => p.LeaveBalanceHistories)
                .HasForeignKey(d => d.OperatorId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_LeaveBalanceHistories_Operator");
        });

        modelBuilder.Entity<LeaveRequest>(entity =>
        {
            entity.HasIndex(e => e.EmployeeId, "IX_LeaveRequests_EmployeeId");

            entity.HasIndex(e => e.Status, "IX_LeaveRequests_Status");

            entity.Property(e => e.ApprovedAt).HasPrecision(0);
            entity.Property(e => e.CancelReason).HasMaxLength(300);
            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(getdate())");
            entity.Property(e => e.DaysUsed).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.EndDate).HasColumnType("datetime");
            entity.Property(e => e.HoursUsed).HasColumnType("decimal(18, 1)");
            entity.Property(e => e.OriginalStatus).HasMaxLength(20);
            entity.Property(e => e.Reason).HasMaxLength(500);
            entity.Property(e => e.RejectReason).HasMaxLength(300);
            entity.Property(e => e.StartDate).HasColumnType("datetime");
            entity.Property(e => e.Status)
                .HasMaxLength(20)
                .HasDefaultValue("Pending");

            entity.HasOne(d => d.ApprovedByNavigation).WithMany(p => p.LeaveRequestApprovedByNavigations)
                .HasForeignKey(d => d.ApprovedBy)
                .HasConstraintName("FK_Leave_ApprovedBy");

            entity.HasOne(d => d.Employee).WithMany(p => p.LeaveRequestEmployees)
                .HasForeignKey(d => d.EmployeeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Leave_Employee");

            entity.HasOne(d => d.LeaveDelegate).WithMany(p => p.LeaveRequestLeaveDelegates)
                .HasForeignKey(d => d.LeaveDelegateId)
                .HasConstraintName("FK_Leave_LeaveDelegate");

            entity.HasOne(d => d.LeaveType).WithMany(p => p.LeaveRequests)
                .HasForeignKey(d => d.LeaveTypeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Leave_LeaveType");
        });

        modelBuilder.Entity<LeaveType>(entity =>
        {
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.Name).HasMaxLength(30);
            entity.Property(e => e.QuotaType)
                .HasMaxLength(20)
                .HasDefaultValue("PreAllocated");
        });

        modelBuilder.Entity<Member>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Members__3214EC072D5B4E94");

            entity.Property(e => e.ActivityLevel).HasMaxLength(50);
            entity.Property(e => e.Bmr).HasColumnName("BMR");
            entity.Property(e => e.CancelCount).HasDefaultValue(1);
            entity.Property(e => e.DateOfBirth).HasPrecision(0);
            entity.Property(e => e.ImageUrl).HasMaxLength(300);
            entity.Property(e => e.Target).HasMaxLength(50);
            entity.Property(e => e.Tdee).HasColumnName("TDEE");

            entity.HasOne(d => d.User).WithMany(p => p.Members)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Members_Users");
        });

        modelBuilder.Entity<MemberViolation>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__MemberVi__3214EC077ED072F2");

            entity.HasIndex(e => e.MemberId, "UQ_MemberViolations_MemberId").IsUnique();

            entity.Property(e => e.LastWarningAt).HasPrecision(0);
            entity.Property(e => e.Reason).HasMaxLength(500);
            entity.Property(e => e.SuspendedAt).HasPrecision(0);

            entity.HasOne(d => d.Member).WithOne(p => p.MemberViolation)
                .HasForeignKey<MemberViolation>(d => d.MemberId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_MemberViolations_Members");
        });

        modelBuilder.Entity<Notification>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Notifica__3214EC0716B5BE47");

            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(getdate())");
            entity.Property(e => e.NotifyType).HasMaxLength(50);
            entity.Property(e => e.Title).HasMaxLength(100);

            entity.HasOne(d => d.Sender).WithMany(p => p.NotificationSenders)
                .HasForeignKey(d => d.SenderId)
                .HasConstraintName("FK_Notifications_Users_Sender");

            entity.HasOne(d => d.User).WithMany(p => p.NotificationUsers)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Notifications_Users_Receiver");
        });

        modelBuilder.Entity<Nutrient>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Nutrient__3214EC0746474EAC");

            entity.Property(e => e.Measure).HasMaxLength(20);

            entity.HasOne(d => d.Food).WithMany(p => p.Nutrients)
                .HasForeignKey(d => d.FoodId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Nutrients_Foods");
        });

        modelBuilder.Entity<PointOrder>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__PointOrd__3214EC0746269E1A");

            entity.Property(e => e.CreateAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.DiscountedPrice).HasColumnType("decimal(18, 0)");
            entity.Property(e => e.OriginalPrice).HasColumnType("decimal(18, 0)");

            entity.HasOne(d => d.Member).WithMany(p => p.PointOrders)
                .HasForeignKey(d => d.MemberId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PointOrders_Members");

            entity.HasOne(d => d.TopUpPlan).WithMany(p => p.PointOrders)
                .HasForeignKey(d => d.TopUpPlanId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PointOrders_TopUpPlans");
        });

        modelBuilder.Entity<PointsRecordDetail>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__PointsRe__3214EC077E025FEF");

            entity.Property(e => e.CreateAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(getdate())");
            entity.Property(e => e.MerchandiseCategory).HasMaxLength(50);

            entity.HasOne(d => d.PointOrder).WithMany(p => p.PointsRecordDetails)
                .HasForeignKey(d => d.PointOrderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PointsRecordDetails_PointOrders");

            entity.HasOne(d => d.ReserveOrder).WithMany(p => p.PointsRecordDetails)
                .HasForeignKey(d => d.ReserveOrderId)
                .HasConstraintName("FK_PointsRecordDetails_ReserveOrders");

            entity.HasOne(d => d.UserWallet).WithMany(p => p.PointsRecordDetails)
                .HasForeignKey(d => d.UserWalletId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_PointsRecordDetails_UserWallets");
        });

        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Products__3214EC0794CE8449");

            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.Name).HasMaxLength(100);
            entity.Property(e => e.OriginalPrice).HasColumnType("decimal(18, 0)");
            entity.Property(e => e.UnitPrice).HasColumnType("decimal(18, 0)");

            entity.HasOne(d => d.Category).WithMany(p => p.Products)
                .HasForeignKey(d => d.CategoryId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Products_ProductCategories");
        });

        modelBuilder.Entity<ProductCategory>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__ProductC__3214EC07210FCC69");

            entity.Property(e => e.CategoryName).HasMaxLength(50);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
        });

        modelBuilder.Entity<ProductOrder>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__ProductO__3214EC07A1E71CF3");

            entity.Property(e => e.Address).HasMaxLength(500);
            entity.Property(e => e.CreateAt).HasDefaultValueSql("(getdate())");
            entity.Property(e => e.DiscountAmount).HasColumnType("decimal(18, 0)");
            entity.Property(e => e.Memo).HasMaxLength(50);
            entity.Property(e => e.Mobile)
                .HasMaxLength(20)
                .IsUnicode(false);
            entity.Property(e => e.OriginalAmount).HasColumnType("decimal(18, 0)");
            entity.Property(e => e.Receiver).HasMaxLength(30);

            entity.HasOne(d => d.Member).WithMany(p => p.ProductOrders)
                .HasForeignKey(d => d.MemberId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ProductOrders_Members");
        });

        modelBuilder.Entity<ProductOrderDetail>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__ProductO__3214EC077D02DF9E");

            entity.Property(e => e.DiscountedPrice).HasColumnType("decimal(18, 0)");
            entity.Property(e => e.ImageUrl)
                .HasMaxLength(300)
                .HasColumnName("ImageURL");
            entity.Property(e => e.Memo).HasMaxLength(50);
            entity.Property(e => e.ProductName).HasMaxLength(50);
            entity.Property(e => e.SubTotal).HasColumnType("decimal(18, 0)");
            entity.Property(e => e.UnitPrice).HasColumnType("decimal(18, 0)");

            entity.HasOne(d => d.Product).WithMany(p => p.ProductOrderDetails)
                .HasForeignKey(d => d.ProductId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ProductOrderDetails_Products");

            entity.HasOne(d => d.ProductOrder).WithMany(p => p.ProductOrderDetails)
                .HasForeignKey(d => d.ProductOrderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ProductOrderDetails_ProductOrders");
        });

        modelBuilder.Entity<ReserveOrder>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__ReserveO__3214EC074B699A73");

            entity.Property(e => e.CreateAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(getdate())");
            entity.Property(e => e.Memorandum).HasMaxLength(100);
            entity.Property(e => e.PaymentMethod).HasMaxLength(10);
            entity.Property(e => e.Price).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.Status).HasMaxLength(10);
            entity.Property(e => e.Target).HasMaxLength(300);

            entity.HasOne(d => d.Member).WithMany(p => p.ReserveOrders)
                .HasForeignKey(d => d.MemberId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ReserveOrders_Members");

            entity.HasOne(d => d.Shift).WithMany(p => p.ReserveOrders)
                .HasForeignKey(d => d.ShiftId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ReserveOrders_Shifts");
        });

        modelBuilder.Entity<Review>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Reviews__3214EC077894FF45");

            entity.Property(e => e.Comment).HasMaxLength(500);
            entity.Property(e => e.CreatedAt)
                .HasPrecision(0)
                .HasDefaultValueSql("(getdate())");

            entity.HasOne(d => d.Instructor).WithMany(p => p.Reviews)
                .HasForeignKey(d => d.InstructorId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Reviews_Instructors");

            entity.HasOne(d => d.Member).WithMany(p => p.Reviews)
                .HasForeignKey(d => d.MemberId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Reviews_Members");

            entity.HasOne(d => d.ReserveOrder).WithMany(p => p.Reviews)
                .HasForeignKey(d => d.ReserveOrderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Reviews_ReserveOrders");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Roles__3214EC07E03FBEE1");

            entity.HasIndex(e => e.RoleName, "UQ_Roles_RoleName").IsUnique();

            entity.Property(e => e.RoleName).HasMaxLength(30);
        });

        modelBuilder.Entity<RoleFunction>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__RoleFunc__3214EC07E2982B89");

            entity.HasIndex(e => new { e.RoleId, e.FunctionId }, "UQ_RoleFunctions").IsUnique();

            entity.HasOne(d => d.Function).WithMany(p => p.RoleFunctions)
                .HasForeignKey(d => d.FunctionId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_RoleFunctions_Function");

            entity.HasOne(d => d.Role).WithMany(p => p.RoleFunctions)
                .HasForeignKey(d => d.RoleId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_RoleFunctions_Role");
        });


        modelBuilder.Entity<Shift>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Shifts__3214EC0706043F02");

            entity.Property(e => e.TimeSlot).HasMaxLength(20);

            entity.HasOne(d => d.Instructor).WithMany(p => p.Shifts)
                .HasForeignKey(d => d.InstructorId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Shifts_Instructors");
        });

        modelBuilder.Entity<TopUpPlan>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__TopUpPla__3214EC07E1DBA0D1");

            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.PlanName).HasMaxLength(50);
            entity.Property(e => e.Price).HasColumnType("decimal(18, 0)");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Users__3214EC07CC1AB30B");

            entity.HasIndex(e => e.Email, "UQ_Users_Email").IsUnique();

            entity.HasIndex(e => e.Account, "UX_Users_Account")
                .IsUnique()
                .HasFilter("([Account] IS NOT NULL)");

            entity.Property(e => e.Account).HasMaxLength(50);
            entity.Property(e => e.Email).HasMaxLength(200);
            entity.Property(e => e.HashedPassword).HasMaxLength(256);
            entity.Property(e => e.Mobile)
                .HasMaxLength(10)
                .IsUnicode(false);
            entity.Property(e => e.NewMemberConfirmCode)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.NewMemberConfirmCodeExpiry).HasPrecision(0);
            entity.Property(e => e.ResetPasswordConfirmCode)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.ResetPasswordConfirmCodeExpiry).HasPrecision(0);
            entity.Property(e => e.UserName).HasMaxLength(30);
        });

        modelBuilder.Entity<UserExternalLogin>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__UserExte__3214EC07B9C01568");

            entity.Property(e => e.LoginProvider).HasMaxLength(50);
            entity.Property(e => e.ProviderDisplayName).HasMaxLength(100);
            entity.Property(e => e.ProviderKey).HasMaxLength(255);

            entity.HasOne(d => d.User).WithMany(p => p.UserExternalLogins)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ExternalLogins_Users");
        });

        modelBuilder.Entity<UserRole>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__UserRole__3214EC07180DE493");

            entity.HasIndex(e => new { e.UserId, e.RoleId }, "UQ_UserRoles").IsUnique();

            entity.HasOne(d => d.Role).WithMany(p => p.UserRoles)
                .HasForeignKey(d => d.RoleId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserRoles_Role");

            entity.HasOne(d => d.User).WithMany(p => p.UserRoles)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserRoles_User");
        });

        modelBuilder.Entity<UserWallet>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__UserWall__3214EC077ED5CDA6");

            entity.HasIndex(e => e.MemberId, "UQ_UserWallets_Member").IsUnique();

            entity.Property(e => e.CurrentBalance).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.LastUpdated)
                .HasPrecision(0)
                .HasDefaultValueSql("(getdate())");

            entity.HasOne(d => d.Member).WithOne(p => p.UserWallet)
                .HasForeignKey<UserWallet>(d => d.MemberId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserWallets_Members");
        });

        modelBuilder.Entity<VwEmployeeDeptInfo>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("vw_EmployeeDeptInfo");

            entity.Property(e => e.DepartmentName).HasMaxLength(50);
            entity.Property(e => e.ManagerName).HasMaxLength(30);
            entity.Property(e => e.Role).HasMaxLength(30);
            entity.Property(e => e.UserName).HasMaxLength(30);
            entity.Property(e => e.WorkDelegateName).HasMaxLength(30);
        });

        modelBuilder.Entity<VwRoleFunction>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("vw_RoleFunctions");

            entity.Property(e => e.FunctionName).HasMaxLength(50);
            entity.Property(e => e.RoleName).HasMaxLength(30);
        });

        modelBuilder.Entity<VwUserMemberFoodRecord>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("vw_UserMemberFoodRecord");

            entity.Property(e => e.Bmr).HasColumnName("BMR");
            entity.Property(e => e.CategoryName).HasMaxLength(50);
            entity.Property(e => e.EatDt)
                .HasPrecision(0)
                .HasColumnName("EatDT");
            entity.Property(e => e.Email).HasMaxLength(200);
            entity.Property(e => e.FoodName).HasMaxLength(50);
            entity.Property(e => e.MealType).HasMaxLength(20);
            entity.Property(e => e.NutrientMeasure).HasMaxLength(20);
            entity.Property(e => e.RecordMeasure).HasMaxLength(20);
            entity.Property(e => e.Tdee).HasColumnName("TDEE");
            entity.Property(e => e.UserName).HasMaxLength(30);
        });

        modelBuilder.Entity<VwUserRoleFunction>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("vw_UserRoleFunction");

            entity.Property(e => e.Email).HasMaxLength(200);
            entity.Property(e => e.FunctionName).HasMaxLength(50);
            entity.Property(e => e.RoleName).HasMaxLength(30);
            entity.Property(e => e.UserName).HasMaxLength(30);
        });

        modelBuilder.Entity<VwUserRoleFunction1>(entity =>
        {
            entity
                .HasNoKey()
                .ToView("vw_UserRoleFunctions");

            entity.Property(e => e.Account).HasMaxLength(50);
            entity.Property(e => e.FunctionName).HasMaxLength(50);
            entity.Property(e => e.RoleName).HasMaxLength(30);
            entity.Property(e => e.UserName).HasMaxLength(30);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
