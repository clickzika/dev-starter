USE [FIN_REG_LHF]
GO

/****** Object:  StoredProcedure [dbo].[LHFGetSwitchingEffectiveDateUseInternettrading]    Script Date: 5/28/2026 5:34:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER   PROCEDURE [dbo].[LHFGetSwitchingEffectiveDateUseInternettrading]
	@FundIDInput int,
	@CounterFundIDInput int,
	@OrderDateInput date,
	@OrderUnitTypeInput varchar(20),
	@OrderUnitInput numeric(18,4),
	@OrderAmountInput decimal(18,2),
	@EffectiveDateOutput date out,
	@PaidDateOutput date out,
	@PaymentDateOutput date out,
	@SWOPaymentDate date = null out,
	@ErrorCodeOutput varchar(20) = '' out,
	@ErrorMsgOutput varchar(max) = '' out
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	set @EffectiveDateOutput = null
	set @PaidDateOutput  = null
	set @PaymentDateOutput = null
	set @SWOPaymentDate = null
	set @ErrorCodeOutput = ''
	set @ErrorMsgOutput = ''
	Declare @CheckLoop int = 0

	/*SWO*/
	declare 
	@FundCode varchar(50),
	@RedemptionDays int,
	@NavDays int,
	@UseRedemptionDates bit,
	@FundSubType varchar(50),
	@MinimumSellAmount decimal(18,2),
	@MinimumSellUnit decimal(18,4),
	@MasterFundID int
	/*End SWO*/
	/*SWI*/
	declare
	@CounterFundCode varchar(50),
	@CounterUseSubscriptionDates bit,
	@CounterFundIPOFromDate date,
	@CounterFundIPOToDate date,
	@CounterFundFundSubType varchar(20),
	@CounterFundMinimumIPOAmount decimal(18,2),
	@CounterFundMinimumBuyAmount decimal(18,2),
	@CounterFundSubType varchar(50),
	@CounterFundMasterFundID int
	
	/*End SWI*/

	/*Get Fund Data ของ SWO*/
	select @FundCode = f.FundCode
	,@RedemptionDays = RedemptionDays
	,@NavDays = NavDays
	,@UseRedemptionDates = UseRedemptionDates
	,@FundSubType = FundSubType
	,@MinimumSellAmount = f.MinimumSellAmount
	,@MinimumSellUnit = f.MinimumSellUnit
	,@MasterFundID = f.ReferenceFundID
	from Fund as f
	where f.FundID = @FundIDInput
	/*End Get Fund Data ของ SWO*/

	/*Get Fund Data ของ SWI*/
	select @CounterFundCode = f.FundCode
	,@CounterUseSubscriptionDates = UseSubscriptionDates
	,@CounterFundIPOFromDate = IPOFromDate
	,@CounterFundIPOToDate = IPOToDate
	,@CounterFundFundSubType = FundSubType
	,@CounterFundMinimumIPOAmount = MinimumIPOAmount
	,@CounterFundMinimumBuyAmount = MinimumBuyAmount
	,@CounterFundSubType = FundSubType
	,@CounterFundMasterFundID = ReferenceFundID
	from Fund as f
	where f.FundID = @CounterFundIDInput
	/*End Get Fund Data ของ SWI*/

	--select @FundCode as FundCode
	--,@RedemptionDays as RedemptionDays
	--,@NavDays as NavDays
	--,@UseRedemptionDates as UseRedemptionDates
	--,@FundSubType as FundSubType
	--,@MinimumSellAmount as MinimumSellAmount
	--,@MinimumSellUnit as MinimumSellUnit	
	--,@MasterFundID as MasterFundID

	--select @CounterFundCode as FundCode
	--,@CounterUseSubscriptionDates as UseSubscriptionDates
	--,@CounterFundIPOFromDate as IPOFromDate
	--,@CounterFundIPOToDate as IPOToDate
	--,@CounterFundFundSubType as FundSubType
	--,@CounterFundMinimumIPOAmount as MinimumIPOAmount
	--,@CounterFundMinimumBuyAmount as MinimumBuyAmount
	--,@CounterFundSubType as FundSubType
	--,@CounterFundMasterFundID as ReferenceFundID

	/*Check ขั้นต่ำ*/
	if @OrderUnitTypeInput = 'Amount'
	begin
		/*SWO*/
		if @OrderAmountInput < @MinimumSellAmount
		begin
			set @ErrorCodeOutput = '009'
			set @ErrorMsgOutput = 'โดยกอง ' + @FundCode + ' กำหนดขั้นต่ำ ' + CONVERT(varchar, CAST(@MinimumSellAmount AS money), 1) + ' บาท'
			goto Exit2;			
		end
		/*End SWO*/
		/*SWI*/
		/*SWI ในช่วง IPO*/
		if @OrderDateInput between @CounterFundIPOFromDate and @CounterFundIPOToDate
		begin
			if @OrderAmountInput < @CounterFundMinimumIPOAmount
			begin
				set @ErrorCodeOutput = '003'
				set @ErrorMsgOutput = 'โดยกอง ' + @CounterFundCode + ' กำหนดขั้นต่ำในช่วง IPO ' + CONVERT(varchar, CAST(@CounterFundMinimumIPOAmount AS money), 1) + ' บาท'
				goto Exit2;
			end
		end
		/*END SWI ในช่วง IPO*/
		else
		begin
			if @OrderAmountInput < @CounterFundMinimumBuyAmount
			begin
				set @ErrorCodeOutput = '004'
				set @ErrorMsgOutput = 'โดยกอง ' + @CounterFundCode + ' กำหนดขั้นต่ำ ' + CONVERT(varchar, CAST(@CounterFundMinimumBuyAmount AS money), 1) + ' บาท'
				goto Exit2;
			end
		end
		/*END SWI*/
	end
	else
	begin
	begin
		/*SWO*/
		if @OrderUnitInput < @MinimumSellUnit and @OrderUnitTypeInput <> 'All'
		begin		
			set @ErrorCodeOutput = '010'
			set @ErrorMsgOutput = 'โดยกอง ' + @FundCode + ' กำหนดขั้นต่ำ ' + CONVERT(varchar, CAST(@MinimumSellUnit AS money), 2) + ' หน่วย'
			goto Exit2;
		end		
		/*END SWO*/
		
		declare @NAVPerUnitSWO decimal(18,4)
		set @NAVPerUnitSWO = 0

		select @NAVPerUnitSWO = fnn.NAVPerUnit
		from FundNAV as fnn
		where fnn.FundID = @FundIDInput
		and fnn.NAVDate in(select max(fn.NAVDate) from FundNAV as fn  where fn.FundID = @FundIDInput)
		declare @OrderAmountSWO decimal(18,2)
		set @OrderAmountSWO = round(@OrderUnitInput * @NAVPerUnitSWO,2)
		/*SWI ในช่วง IPO*/
		if @OrderDateInput between @CounterFundIPOFromDate and @CounterFundIPOToDate
		begin
			if @OrderAmountSWO < @CounterFundMinimumIPOAmount
			begin
				set @ErrorCodeOutput = '003'
				set @ErrorMsgOutput = 'โดยกอง ' + @FundCode + ' กำหนดขั้นต่ำในช่วง IPO ' + CONVERT(varchar, CAST(@CounterFundMinimumIPOAmount AS money), 1) + ' บาท'
				goto Exit2;
			end
		end	
		/*SWI ในช่วง IPO*/	
		else
		begin
			if @OrderAmountSWO < @CounterFundMinimumBuyAmount
			begin
				set @ErrorCodeOutput = '004'
				set @ErrorMsgOutput = 'โดยกอง ' + @FundCode + ' กำหนดขั้นต่ำ ' + CONVERT(varchar, CAST(@CounterFundMinimumBuyAmount AS money), 1) + ' บาท'
				goto Exit2;
			end			
		end
	end
	/*End Check ขั้นต่ำ*/


	/*Cal EffectiveDate*/
	set @EffectiveDateOutput = @OrderDateInput;
	/*เป็นกอง SubClass ที่มีกองแม่กองเดียวกัน*/
	if @FundSubType = 'Sub_Fund' and @CounterFundSubType = 'Sub_Fund' and (@MasterFundID = @CounterFundMasterFundID)
	begin
		--set @RedemptionDays = 1
		set @RedemptionDays = 0
		set @EffectiveDateOutput = @OrderDateInput;
	end
	/*End เป็นกอง SubClass ที่มีกองแม่กองเดียวกัน*/
	/*เป็นกอง Rollover*/
	if @FundSubType = 'Rollover'
	begin
		select @EffectiveDateOutput = max(fs.EffectiveDate)
		from FundSchedule as fs 
		where fs.FundID = @FundIDInput
		and  @OrderDateInput between fs.RedemptionFromDate and fs.RedemptionToDate		

		if @EffectiveDateOutput is null
		begin
			set @ErrorCodeOutput = '013'
			set @ErrorMsgOutput = 'ของกอง ' + @FundCode		
			goto Exit2;
		end
	end
	/*End เป็นกอง Rollover*/
	/*NavDays > 0*/
	if @NavDays > 0
	begin
		Set @EffectiveDateOutput = dbo.GetNextOrLastWorkingDate(@FundIDInput,@OrderDateInput,@NavDays,'False')
	end
	/*End NavDays > 0*/
	/*Is useRedemptionDates*/
	if @UseRedemptionDates = 'True' 
	begin
		select @EffectiveDateOutput = min(ts.TradeableDate)
		from TradeScheduleDates as ts
		where ts.OrderTxTypes like '%Redemption%'
		and ts.FundID = @FundIDInput
		and ts.TradeableDate >= @OrderDateInput		
		if @EffectiveDateOutput is null
		begin
			set @ErrorCodeOutput = '015'
			set @ErrorMsgOutput = ' ไม่พบข้อมูล Tradeable Date ของกอง ' + @FundCode + ' เนื่องจากเป็นกองที่ขายเฉพาะวันแรกของสัปดาห์'
			goto Exit2;			
		end

	end
   
	
	/*ตรวจสอบวันหยุด*/
	Declare @CheckHoliday bit

	set @CheckHoliday = dbo.IsHolidayOrWeekEndIncludedBookCloseDate(@FundIDInput, @EffectiveDateOutput)
	if @CheckHoliday = 'False'
	begin
		goto CalEffectiveDate;
	end
	WHILE @CheckHoliday = 'True'
	begin
		set @EffectiveDateOutput = dbo.GetNextOrLastWorkingDate(@FundIDInput,@EffectiveDateOutput,1,'False')
		set @CheckHoliday = dbo.IsHolidayOrWeekEndIncludedBookCloseDate(@FundIDInput, @EffectiveDateOutput)
		if @CheckHoliday = 'False'
		begin
			goto CalEffectiveDate;
		end
	end 
	/*End ตรวจสอบวันหยุด*/

	/*End Cal EffectiveDate*/	

	CalEffectiveDate:

	set @CheckLoop = @CheckLoop + 1
	if @CheckLoop > 9
	begin
		set @ErrorCodeOutput = '017'
		set @ErrorMsgOutput = ' ไม่สามารถ Switching Out จากกอง ' + @FundCode + ' เพื่อ Switching In เข้ากอง ' + @CounterFundCode	+ ' กรุณาติดต่อเจ้าหน้าที่'
		goto Exit2;				
	end

	/*Cal PaymentDate*/
	declare @CheckHolidaySWO bit
	declare @CheckHolidaySWI bit
	declare @CheckHolidayPaymentDate bit
	declare @InvalidDate bit = 'False'

	if @FundSubType = 'Rollover'
	begin
		select @PaidDateOutput = fs.PaidDate
		from FundSchedule as fs
		where fs.FundID = @FundIDInput
		and fs.EffectiveDate = @EffectiveDateOutput
		set @PaymentDateOutput =  dbo.GetNextOrLastWorkingDate(0,@PaidDateOutput,1,'True')
		set @SWOPaymentDate = @PaidDateOutput
	end
	else
	begin
		set @PaidDateOutput = dbo.GetNextOrLastWorkingDate(@FundIDInput,@EffectiveDateOutput,@RedemptionDays,'False')
		set @PaymentDateOutput =  dbo.GetNextOrLastWorkingDate(0,@PaidDateOutput,1,'True')
		set @SWOPaymentDate = @PaidDateOutput

		/* ===== FIX 2026-04-29 (ported from GetSwitchingEffectiveUseInternetrading) =====
		   If SWI PaymentDate (unit-receive date) falls on Holiday/WeekEnd/BookClose
		   of the counter fund (SWI), advance PaymentDate forward, then recalc
		   PaidDate = PaymentDate + 1 working day.
		*/
		WHILE dbo.IsHolidayOrWeekEndIncludedBookCloseDate(@CounterFundIDInput, @PaymentDateOutput) = 'True'
		BEGIN
			set @PaymentDateOutput = dbo.GetNextOrLastWorkingDate(0, @PaymentDateOutput, 1, 'False')
		END
		set @PaidDateOutput = dbo.GetNextOrLastWorkingDate(0, @PaymentDateOutput, 1, 'False')
		/* ===== END FIX ===== */

		/*Switching In เข้ากอง Rollover*/
		if @OrderDateInput between @CounterFundIPOFromDate and @CounterFundIPOToDate
		begin
			set @PaymentDateOutput = @CounterFundIPOToDate
			set @PaidDateOutput = dbo.GetNextOrLastWorkingDate(@FundIDInput,@PaymentDateOutput,1,'False')
		end
		/*End Switching In เข้ากอง Rollover*/
		/*Switching In เข้ากอง Rollover*/
		if @CounterFundFundSubType = 'Rollover'
		begin
			select @PaymentDateOutput = max(fs.EffectiveDate)
			from FundSchedule as fs
			where fs.FundID = @CounterFundIDInput
			and @OrderDateInput between fs.SubscriptionFromDate and fs.SubscriptionToDate	
			if @PaymentDateOutput is null
			begin
				set @ErrorCodeOutput = '020'
				set @ErrorMsgOutput = ' ของกอง ' + @FundCode + ' กรุณาติดต่อเจ้าหน้าที่' 
				goto Exit2;				
			end 	
			set @PaidDateOutput = dbo.GetNextOrLastWorkingDate(@FundIDInput,@PaymentDateOutput,1,'False')
		end
		/*End Switching In เข้ากอง Rollover*/
		/*Is UseSubscriptionDates*/
		if @CounterUseSubscriptionDates = 'True'
		begin
			declare @TradeableDateSub date
			select @TradeableDateSub = min(ts.TradeableDate)
			from TradeScheduleDates as ts
			where ts.OrderTxTypes like '%Subscription%'
			and ts.FundID = @CounterFundIDInput
			and ts.TradeableDate >= @PaymentDateOutput
			if @TradeableDateSub is null
			begin
				set @ErrorCodeOutput = '021'
				set @ErrorMsgOutput = ' ไม่พบข้อมูล Tradeable Date ของกอง ' + @CounterFundCode + ' เนื่องจากเป็นกองที่ซื้อเฉพาะวันแรกของสัปดาห์'
				goto Exit2;				
			end
			set @PaymentDateOutput = @TradeableDateSub;
			set @PaidDateOutput = dbo.GetNextOrLastWorkingDate(@FundIDInput,@PaymentDateOutput,1,'False')
		end
		/*End Is UseSubscriptionDates*/
	end

	/*ตรวจสอบวันหยุด*/
	set @CheckHolidaySWO = dbo.IsHolidayOrWeekEnd(@FundIDInput, @PaidDateOutput) 
	set @CheckHolidaySWI = dbo.IsHolidayOrWeekEnd(@CounterFundIDInput, @PaidDateOutput) 
	if (@CheckHolidaySWO = 'True' or @CheckHolidaySWI = 'True')
	begin
		set @InvalidDate = 'True'
	end

	set @CheckHolidayPaymentDate = dbo.IsHolidayOrWeekEndIncludedBookCloseDate(@CounterFundIDInput, @PaymentDateOutput)
	if @CheckHolidayPaymentDate = 'True'
	begin
		set @InvalidDate = 'True'
	end
	
	/*Skip PaymentDate:*/
	WHILE @InvalidDate = 'True'
	begin
		set @PaidDateOutput = dbo.GetNextOrLastWorkingDate(@FundIDInput,@PaidDateOutput,1,'False')	
		set @CheckHolidaySWO = dbo.IsHolidayOrWeekEnd(@FundIDInput, @PaidDateOutput) 
		set @CheckHolidaySWI = dbo.IsHolidayOrWeekEnd(@CounterFundIDInput, @PaidDateOutput) 
		if (@CheckHolidaySWO = 'True' or @CheckHolidaySWI = 'True')
		begin
			set @InvalidDate = 'True'
		end
		else
		begin
			set @PaymentDateOutput =  dbo.GetNextOrLastWorkingDate(0,@PaidDateOutput,1,'True') 
			set @CheckHolidayPaymentDate = dbo.IsHolidayOrWeekEndIncludedBookCloseDate(@CounterFundIDInput, @PaymentDateOutput)
			if @CheckHolidayPaymentDate = 'True'
			begin
				set @InvalidDate = 'True'
			end
			else
			begin
				set @InvalidDate = 'False'
			end
		end
	end
	/*End ตรวจสอบวันหยุด*/

	/*ตรวจสอบ Paid Date และ Payment Date ว่าตรงเงื่อนไขกับประเภทของกองไหม*/
	/*SWO เป็น Rollover*/
	if @FundSubType = 'Rollover'
	begin
		declare @PaidDateOfRollover date
		select @PaidDateOfRollover = fs.PaidDate
		from FundSchedule as fs 
		where fs.FundID = @FundIDInput
		and fs.EffectiveDate = @EffectiveDateOutput
		if @PaidDateOfRollover <> @PaidDateOutput
		begin
			set @ErrorCodeOutput = '014'
			set @ErrorMsgOutput = ' ไม่สามารถ Switching Out จากกอง ' + @FundCode + ' เพื่อ Switching In เข้ากอง ' + @CounterFundCode	
			goto Exit2;			
		end
	end 
	/*End SWO �� Rollover*/
	/*Switching In 㹪�ҧ IPO*/
	if @OrderDateInput between @CounterFundIPOFromDate and @CounterFundIPOToDate
	begin
		if @CounterFundIPOToDate <> @PaymentDateOutput
		begin
			set @ErrorCodeOutput = '016'
			set @ErrorMsgOutput = ' ไม่สามารถ Switching Out จากกอง ' + @FundCode + ' เพื่อ Switching In เข้ากอง ' + @CounterFundCode	+ ' ในช่วง IPO ได้'
			goto Exit2;			
		end
	end
	/*End Switching In ในช่าง IPO*/

	/*End ตรวจสอบ Paid Date และ Payment Date ว่าตรงเงื่อนไขกับประเภทของกองไหม*/

	/*หลังจากหา Paid Date แล้ว คำนวน EffectiveDate ใหม่อีกครั้ง*/	
	
	set @EffectiveDateOutput =  dbo.GetNextOrLastWorkingDate(@FundIDInput,@PaidDateOutput,@RedemptionDays,'True')	
	set @CheckHoliday = dbo.IsHolidayOrWeekEndIncludedBookCloseDate(@FundIDInput, @EffectiveDateOutput)
	if @CheckHoliday = 'False'
	begin
		/*Is useRedemptionDates*/
		if @UseRedemptionDates = 'True' 
		begin
			declare @TradeableDate date
			select @TradeableDate = min(ts.TradeableDate)
			from TradeScheduleDates as ts
			where ts.OrderTxTypes like '%Redemption%'
			and ts.FundID = @FundIDInput
			and ts.TradeableDate >= @OrderDateInput	

			if @TradeableDate is null
			begin
				set @ErrorCodeOutput = '015'
				set @ErrorMsgOutput = ' ไม่พบข้อมูล Tradeable Date ของกอง ' + @FundCode + ' เนื่องจากเป็นกองที่ขายเฉพาะวันแรกของสัปดาห์'
				goto Exit2;			
			end
			if @TradeableDate <> @EffectiveDateOutput
			begin
				declare @NewEffectiveDate date
				set @NewEffectiveDate = @EffectiveDateOutput

				select @EffectiveDateOutput = min(ts.TradeableDate)
				from TradeScheduleDates as ts
				where ts.OrderTxTypes like '%Redemption%'
				and ts.FundID = @FundIDInput
				and ts.TradeableDate >= @NewEffectiveDate		
				if @EffectiveDateOutput is null
				begin
					set @ErrorCodeOutput = '015'
					set @ErrorMsgOutput = ' ไม่พบข้อมูล Tradeable Date ของกอง ' + @FundCode + ' เนื่องจากเป็นกองที่ขายเฉพาะวันแรกของสัปดาห์'
					goto Exit2;			
				end		
				goto CalEffectiveDate;		 	
			end
		end
		/*End Is useRedemptionDates*/
		goto Exit2;
	end
	WHILE @CheckHoliday = 'True'
	begin
		set @EffectiveDateOutput = dbo.GetNextOrLastWorkingDate(@FundIDInput,@EffectiveDateOutput,1,'False')
		set @CheckHoliday = dbo.IsHolidayOrWeekEndIncludedBookCloseDate(@FundIDInput, @EffectiveDateOutput)
		if @CheckHoliday = 'False'
		begin
			goto CalEffectiveDate;
		end
	end
	
	/*End หลังจากหา Paid Date แล้ว คำนวน EffectiveDate ใหม่อีกครั้ง*/
	/*End Skip PaymentDate:*/
	/*End Cal PaymentDate*/

	Exit2:

	if convert(date,@EffectiveDateOutput) < convert(date,@OrderDateInput)
	begin
		set @ErrorCodeOutput = '019'
		set @ErrorMsgOutput = ''			
	end	

	if @FundCode LIKE '%LTF%' AND @CounterFundCode = 'LHTHAIESGX-LT'
	BEGIN
		set @PaymentDateOutput =  @EffectiveDateOutput
	END 
END
END

GO


