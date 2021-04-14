/*
Copyright 2021 David Fromstein
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

public class FlowSchedulerScheduleAppointment {

    @InvocableMethod(label='Schedule Appointment')
    public static void scheduleAppointment(List<Request> requests) {
        Request request = requests[0];
        ServiceAppointment appointment = FlowSchedulerController.getAppointment(request.serviceAppointmentId);
        appointment.ArrivalWindowStartTime = FlowSchedulerController.getArrivalWindowTime(request.startTimeString);
        appointment.ArrivalWindowEndTime = FlowSchedulerController.getArrivalWindowTime(request.endTimeString);
        update appointment;

        FSL__Scheduling_Policy__c policy = FlowSchedulerController.getPolicy(request.schedulingPolicyId);
        
        FSL.ScheduleService.schedule(policy.Id, request.serviceAppointmentId);
    }

    public class Request {
        @InvocableVariable (label='1. Service Appointment ID' required=true)
        public String serviceAppointmentId;
        @InvocableVariable (label= '2. Arrival Window Start Time' description='Get from the output of the Display Booking Slots screen component' required=true)
        public String startTimeString;
        @InvocableVariable (label= '3. Arrival Window End Time' description='Get from the output of the Display Booking Slots screen component' required=true)
        public String endTimeString;
        @InvocableVariable (label='4. (optional) Scheduling Policy ID' description='Provide a specific Scheduling Policy, or make sure you have a Scheduling Policy set to default for self-scheduling')
        public String schedulingPolicyId;
    }

    public class Response {
        @InvocableVariable public String status;
    }
}