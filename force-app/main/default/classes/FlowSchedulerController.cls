/*
Copyright 2021 David Fromstein
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

public class FlowSchedulerController {

    public class FlowSchedulerException extends Exception {}
    public static String defaultFieldName = 'Default_for_Flow_Scheduler__c';
    
    public static ServiceAppointment getAppointment(String serviceAppointmentId) {
        if (String.isBlank(serviceAppointmentId)) {
            throw new FlowSchedulerException('No Service Appointment ID entered');
        }
        List<ServiceAppointment> appointments = [SELECT Id, ServiceTerritoryId FROM ServiceAppointment WHERE Id =: serviceAppointmentId];
        if (appointments.isEmpty()) {
            throw new FlowSchedulerException('Service Appointment '+ serviceAppointmentId +' not found');
        }
        return appointments[0];
    }

    public static FSL__Scheduling_Policy__c getPolicy(String schedulingPolicyId) {
        List<FSL__Scheduling_Policy__c> policies = new List<FSL__Scheduling_Policy__c>(); 
        if (String.isBlank(schedulingPolicyId))
            policies = Database.query('SELECT Id FROM FSL__Scheduling_Policy__c WHERE '+ defaultFieldName +' = true');
        else
            policies = [SELECT Id FROM FSL__Scheduling_Policy__c WHERE Id =: schedulingPolicyId];
        // If we didn't find a valid Scheduling Policy, throw an exception
        if (policies.isEmpty()) {
            throw new FlowSchedulerException('No Scheduling Policy found: either provide a specific Scheduling Policy or set one as default for self-scheduling');
        }
        System.debug('policy ID = '+ policies[0].Id);
        return policies[0];
    }

    public static ServiceTerritory getTerritory(String serviceTerritoryId) {
        // If the ServiceAppointment has an associated ServiceTerritory, search for that record. If not, search for a default Service Territory
        List<ServiceTerritory> territories = new List<ServiceTerritory>(); 
        if (String.isBlank(serviceTerritoryId)) {
            territories = Database.query('SELECT Id, OperatingHoursId FROM ServiceTerritory WHERE '+ defaultFieldName +' = true');
        }
        else {
            territories = [SELECT OperatingHoursId, OperatingHours.Timezone FROM ServiceTerritory WHERE Id =: serviceTerritoryId];        
        }
        // If we didn't find a valid Service Territory, throw an exception
        if (territories.isEmpty()) {
            throw new FlowSchedulerException('No Service Territory found: either associate the Service Appointment with a Service Territory or a Service Territory as default for self-scheduling');
        }
        return territories[0];
    }

    public static DateTime changeTimeZone(DateTime dt, TimeZone tz) {
        Integer offset = tz.getOffset(dt);
        return DateTime.newInstance(dt.getTime() - offset);
    }

    public static DateTime getArrivalWindowTime(String timeString) {
        return DateTime.valueOfGmt(String.valueOf(JSON.deserialize('"'+ timeString +'"', Datetime.class)));
    }
}