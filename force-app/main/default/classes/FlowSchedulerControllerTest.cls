@isTest
public class FlowSchedulerControllerTest {
    
    @isTest
    public static void runTest() {
        Account acc = new Account(Name='Test Account');
        insert acc;    
        FSL__Scheduling_Policy__c pol = new FSL__Scheduling_Policy__c(Name='Test Policy, not default');
        insert pol;
        OperatingHours oh = new OperatingHours(Name='Test Operating Hours', TimeZone = String.valueOf(UserInfo.getTimeZone()));
        insert oh;
        ServiceTerritory st = new ServiceTerritory(Name='Test Service Territory', OperatingHoursId = oh.Id);
        st.put(FlowSchedulerController.defaultFieldName, true);
        insert st;
        WorkType wt = new WorkType(Name='Test Work Type', EstimatedDuration=60, DurationType = 'Minutes');
        insert wt;
        WorkOrder wo = new WorkOrder(AccountId = acc.Id, Subject='Test Work Order', WorkTypeId = wt.Id);
        insert wo;

        ServiceAppointment sa1 = new ServiceAppointment(Status = 'None', EarliestStartTime = Date.today(), DueDate = Date.today()+30, ParentRecordId = wo.Id);
        insert sa1;

        FlowSchedulerGetSlots.Request getSlotsReq = newGetSlotsReq(sa1.Id, pol.Id);
        List<FlowSchedulerGetSlots.Response> response = FlowSchedulerGetSlots.getSlots(new List<FlowSchedulerGetSlots.Request>{getSlotsReq});

        BookingSlot slot = new BookingSlot();
        slot.grade = 90;
        slot.start = Datetime.now();
        slot.finish = Datetime.now()+100;

        FlowSchedulerScheduleAppointment.Request scheduleApptReq = newScheduleAppointmentReq(sa1.Id, slot.start.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''), slot.finish.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''), pol.Id);
        FlowSchedulerScheduleAppointment.scheduleAppointment(new List<FlowSchedulerScheduleAppointment.Request>{scheduleApptReq});

        FlowSchedulerController.changeTimeZone(Datetime.now(), UserInfo.getTimeZone());

    }

    public static FlowSchedulerGetSlots.Request newGetSlotsReq(Id saId, Id polId) {
        FlowSchedulerGetSlots.Request getSlotsReq = new FlowSchedulerGetSlots.Request();
        getSlotsReq.serviceAppointmentId = saId;
        getSlotsReq.schedulingPolicyId = polId;            
        return getSlotsReq;
    }

    public static FlowSchedulerScheduleAppointment.Request newScheduleAppointmentReq(Id saId, String startString, String endString, Id polId) {
        FlowSchedulerScheduleAppointment.Request scheduleApptReq = new FlowSchedulerScheduleAppointment.Request();
        scheduleApptReq.serviceAppointmentId = saId;
        scheduleApptReq.schedulingPolicyId = polId;   
        scheduleApptReq.startTimeString = startString;
        scheduleApptReq.endTimeString = endString;         
        return scheduleApptReq;
    }
}