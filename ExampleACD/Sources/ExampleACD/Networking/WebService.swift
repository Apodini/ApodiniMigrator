//
//  WebService.swift
//
//  Created by ApodiniMigrator on 31.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Endpoints
public enum WebService {
    /// API call for CreateContact at: contacts
    public static func createContact(contact: Contact) -> ApodiniPublisher<Contact> {
        Contact.createContact(contact: contact)
    }
    
    /// API call for GetContacts at: contacts
    public static func getContacts() -> ApodiniPublisher<[Contact]> {
        Contact.getContacts()
    }
    
    /// API call for GetContact at: contacts/{contactId}
    public static func getContact(contactId: UUID) -> ApodiniPublisher<Contact> {
        Contact.getContact(contactId: contactId)
    }
    
    /// API call for UpdateContact at: contacts/{contactId}
    public static func updateContact(contactId: UUID, mediator: ContactMediator) -> ApodiniPublisher<Contact> {
        Contact.updateContact(contactId: contactId, mediator: mediator)
    }
    
    /// API call for CreateResidence at: residencies
    public static func createResidence(residence: Residence) -> ApodiniPublisher<Residence> {
        Residence.createResidence(residence: residence)
    }
    
    /// API call for GetResidencies at: residencies
    public static func getResidencies() -> ApodiniPublisher<[Residence]> {
        Residence.getResidencies()
    }
    
    /// API call for GetResidence at: residencies/{residenceId}
    public static func getResidenceWithId(residenceId: UUID) -> ApodiniPublisher<Residence> {
        Residence.getResidenceWithId(residenceId: residenceId)
    }
    
    /// API call for DeleteContact at: contacts/{contactId}
    public static func deleteContact(contactId: UUID) -> ApodiniPublisher<Status> {
        Status.deleteContact(contactId: contactId)
    }
    
    /// API call for DeleteResidence at: residencies/{residenceId}
    public static func deleteResidence(residenceId: UUID) -> ApodiniPublisher<Status> {
        Status.deleteResidence(residenceId: residenceId)
    }
}
