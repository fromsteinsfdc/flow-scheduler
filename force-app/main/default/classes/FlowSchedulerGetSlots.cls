public class FlowSchedulerGetSlots {

    final public static boolean useExactAppointment = false;
    public class FlowSchedulerGetSlotsException extends Exception {}

    @InvocableMethod(label='Get Booking Slots')
    public static List<Response> getSlots(List<Request> requests) {
        try {
            Request request = requests[0];

            ServiceAppointment appointment = FlowSchedulerController.getAppointment(request.serviceAppointmentId);
            ServiceTerritory territory = FlowSchedulerController.getTerritory(appointment.serviceTerritoryId);
            OperatingHours operatingHours = [SELECT Id, TimeZone FROM OperatingHours WHERE Id = : territory.OperatingHoursId];
            FSL__Scheduling_Policy__c policy = FlowSchedulerController.getPolicy(request.schedulingPolicyId);
            TimeZone tz = TimeZone.getTimeZone(operatingHours.TimeZone);
            
            List<FSL.AppointmentBookingSlot> slots = FSL.AppointmentBookingService.getSlots(request.serviceAppointmentId, policy.Id, operatingHours.Id, tz, useExactAppointment);
            List<BookingSlot> returnSlots = new List<BookingSlot>();        
            
            for (FSL.AppointmentBookingSlot slot : slots) {
                BookingSlot newResponseSlot = new BookingSlot();
                newResponseSlot.grade = slot.grade;
                newResponseSlot.start = FlowSchedulerController.changeTimeZone(slot.interval.start, tz);            
                newResponseSlot.finish = FlowSchedulerController.changeTimeZone(slot.interval.finish, tz);
                returnSlots.add(newResponseSlot);
            }
            Response response = new Response(returnSlots);
            return new List<Response>{response};
        } catch (FlowSchedulerController.FlowSchedulerException e) {
            Response response = new Response(e.getMessage());
            return new List<Response>{response};
        }
    }
    
    public class Request {
        @InvocableVariable (label='1. Service Appointment ID' required=true)
        public String serviceAppointmentId;

        @InvocableVariable (label='2. (optional) Scheduling Policy ID' description='Provide a specific Scheduling Policy, or make sure you have a Scheduling Policy set to default for self-scheduling')
        public String schedulingPolicyId;
    }

    public class Response {
        @InvocableVariable(label='Matching Slots') 
        public List<BookingSlot> slots;

        @InvocableVariable(label='Error message')
        public String error;

        public Response(List<BookingSlot> slots) {
            this.slots = slots;
        }

        public Response(String error) {
            this.error = error;
        }

    }
}