﻿@appointment
Feature: AppointmentAmend

Scenario Outline: I perform a successful amend appointment and check the returned appointment resources are in the future
	Given I create an Appointment for Patient "<Patient>" and Organization Code "ORG1"
		And I store the Created Appointment
	Given I configure the default "AppointmentAmend" request
		And I set the Created Appointment Description to "customDescription"
	When I make the "AppointmentAmend" request
	Then the response status code should indicate success
		And the Response Resource should be an Appointment
		And the Appointments returned must be in the future
		And the Appointment Metadata should be valid
		And the Appointment Status should be valid
		And the Appointment Start should be valid
		And the Appointment End should be valid
		And the Appointment Slots should be valid
		And the Appointment Participants should be valid and resolvable
		And the Appointment Priority should be valid
		And the Appointment Participant Type and Actor should be valid
		And the Appointment Identifiers should be valid
		And the Appointment Description should be valid for "customDescription"
		And the Appointment Created must be valid
	Examples:
		| Patient  |
		| patient1 |
		| patient2 |
		| patient3 |

Scenario: Amend appointment and update element which cannot be updated
	Given I create an Appointment for an existing Patient and Organization Code "ORG1"
		And I store the Created Appointment
	Given I configure the default "AppointmentAmend" request
		And I set the Created Appointment Priority to "1"
	When I make the "AppointmentAmend" request
	Then the response status code should indicate failure
		And the response should be a OperationOutcome resource with error code "BAD_REQUEST"

Scenario Outline: Amend appointment using the _format parameter to request response format
	Given I create an Appointment for an existing Patient and Organization Code "ORG1"
		And I store the Created Appointment	
	Given I configure the default "AppointmentAmend" request
		And I set the Created Appointment Description to "customDescription"
		And I add a Format parameter with the Value "<Format>"
	When I make the "AppointmentAmend" request
	Then the response status code should indicate success
		And the response body should be FHIR <BodyFormat>
		And the Response Resource should be an Appointment
		And the Appointment Description should be valid for "customDescription"
	Examples:
		| Format                | BodyFormat |
		| application/fhir+json | JSON       |
		| application/fhir+xml  | XML        |

Scenario Outline: Amend appointment using the accept header to request response format
	Given I create an Appointment for an existing Patient and Organization Code "ORG1"
		And I store the Created Appointment	
	Given I configure the default "AppointmentAmend" request
		And I set the Created Appointment Description to "customDescription"
		And I set the Accept header to "<Header>"
	When I make the "AppointmentAmend" request
	Then the response status code should indicate success
		And the response body should be FHIR <BodyFormat>
		And the Response Resource should be an Appointment
		And the Appointment Metadata should be valid
		And the Appointment Description should be valid for "customDescription"
	Examples:
		| Header                | BodyFormat |
		| application/fhir+json | JSON       |
		| application/fhir+xml  | XML        |

Scenario Outline: Amend appointment using the _format and accept parameter to request response format
	Given I create an Appointment for an existing Patient and Organization Code "ORG1"
		And I store the Created Appointment	
	Given I configure the default "AppointmentAmend" request
		And I set the Accept header to "<Header>"
		And I add the parameter "_format" with the value "<Parameter>"
	When I make the "AppointmentAmend" request
	Then the response status code should indicate success
		And the response body should be FHIR <BodyFormat>
		And the Response Resource should be an Appointment
		And the Appointment Metadata should be valid
	Examples:
		| Header                | Parameter             | BodyFormat |
		| application/fhir+json | application/fhir+json | JSON       |
		| application/fhir+json | application/fhir+xml  | XML        |
		| application/fhir+xml  | application/fhir+json | JSON       |
		| application/fhir+xml  | application/fhir+xml  | XML        |
		
Scenario: Amend appointment prefer header set to representation
	Given I create an Appointment for an existing Patient and Organization Code "ORG1"
		And I store the Created Appointment	
	Given I configure the default "AppointmentAmend" request
		And I set the Created Appointment Comment to "customComment"
		And I set the Prefer header to "return=representation"
	When I make the "AppointmentAmend" request
	Then the response status code should indicate success
		And the response body should be FHIR JSON
		And the Response Resource should be an Appointment
		And the content-type should not be equal to null
		And the content-length should not be equal to zero

Scenario: Amend appointment prefer header set to minimal
	Given I create an Appointment for an existing Patient and Organization Code "ORG1"
		And I store the Created Appointment	
	Given I configure the default "AppointmentAmend" request
		And I set the Prefer header to "return=minimal"
	When I make the "AppointmentAmend" request
	Then the response status code should indicate success
		And the response body should be empty

Scenario: Amend appointment send an update with an invalid if-match header
	Given I create an Appointment for an existing Patient and Organization Code "ORG1"
		And I store the Created Appointment	
	Given I configure the default "AppointmentAmend" request
		And I set the Created Appointment Comment to "customComment"
		And I set the If-Match header to "invalidEtag"
	When I make the "AppointmentAmend" request
	Then the response status code should be "409"

Scenario: Amend appointment set etag and check etag is the same in the returned amended appointment
	Given I create an Appointment for an existing Patient and Organization Code "ORG1"		
		And I store the Created Appointment			
	Given I read the Stored Appointment
		And I store the Appointment 
	Given I configure the default "AppointmentAmend" request
		And I set the Created Appointment Comment to "customComment"
		And I set the If-Match header to the Stored Appointment Version Id
	When I make the "AppointmentAmend" request
	Then the response status code should indicate success
		And the Response Resource should be an Appointment
		And the Appointment Comment should be valid for "customComment"

Scenario: Amend appointment and send an invalid bundle resource
	Given I create an Appointment for an existing Patient and Organization Code "ORG1"
		And I store the Created Appointment	
	Given I configure the default "AppointmentAmend" request
		And I set the Created Appointment Comment to "customComment"
	When I make the "AppointmentAmend" request with invalid Resource type
	Then the response status code should be "422"
		And the response should be a OperationOutcome resource with error code "INVALID_RESOURCE"

Scenario: Amend appointment and send an invalid appointment resource
	Given I create an Appointment for an existing Patient and Organization Code "ORG1"
		And I store the Created Appointment	
	Given I configure the default "AppointmentAmend" request
		And I set the Created Appointment to a new Appointment
	When I make the "AppointmentAmend" request
	Then the response status code should be "400"
		And the response should be a OperationOutcome resource with error code "BAD_REQUEST"
				
Scenario: CapabilityStatement profile support the Amend appointment operation
	Given I configure the default "MetadataRead" request
	When I make the "MetadataRead" request
	Then the response status code should indicate success
		And the CapabilityStatement REST Resources should contain the "Appointment" Resource with the "Update" Interaction

Scenario: Amend appointment valid response check caching headers exist
	Given I create an Appointment for an existing Patient and Organization Code "ORG1"
		And I store the Created Appointment
	Given I configure the default "AppointmentAmend" request
		And I set the Created Appointment Description to "customDescription"
	When I make the "AppointmentAmend" request
	Then the response status code should indicate success
		And the Response Resource should be an Appointment
		And the Appointment Description should be valid for "customDescription"
		And the Appointment Metadata should be valid
		And the required cacheing headers should be present in the response

Scenario:Amend appointment invalid response check caching headers exist
	Given I create an Appointment for an existing Patient and Organization Code "ORG1"
		And I store the Created Appointment	
	Given I configure the default "AppointmentAmend" request
		And I set the Created Appointment Comment to "customComment"
		And I set the Created Appointment to a new Appointment
	When I make the "AppointmentAmend" request
	Then the response status code should be "400"
		And the required cacheing headers should be present in the response