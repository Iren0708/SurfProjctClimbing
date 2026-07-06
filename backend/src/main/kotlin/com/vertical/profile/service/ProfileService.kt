package com.vertical.profile.service

import com.vertical.auth.entity.ClientEntity
import com.vertical.auth.repository.AuthSessionRepository
import com.vertical.auth.repository.ClientRepository
import com.vertical.bookings.entity.BookingEntity
import com.vertical.bookings.repository.BookingRepository
import com.vertical.common.exception.NotFoundException
import com.vertical.profile.dto.ClientDto
import com.vertical.profile.dto.toDto
import com.vertical.slots.repository.SlotRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Clock
import java.time.Instant
import java.util.UUID

@Service
class ProfileService(
    private val clientRepository: ClientRepository,
    private val authSessionRepository: AuthSessionRepository,
    private val bookingRepository: BookingRepository,
    private val slotRepository: SlotRepository,
    private val clock: Clock,
) {

    @Transactional(readOnly = true)
    fun getProfile(clientId: UUID): ClientDto =
        loadActiveClient(clientId).toDto()

    @Transactional
    fun updateProfile(clientId: UUID, name: String): ClientDto {
        val client = loadActiveClient(clientId)
        client.name = name.trim()
        return clientRepository.save(client).toDto()
    }

    @Transactional
    fun deleteAccount(clientId: UUID) {
        val client = loadActiveClient(clientId)
        val now = clock.instant()

        cancelActiveBookings(clientId, now)
        revokeSessions(clientId, now)
        anonymizeClient(client, now)
        clientRepository.save(client)
    }

    private fun loadActiveClient(clientId: UUID): ClientEntity =
        clientRepository.findByIdAndDeletedAtIsNull(clientId) ?: throw NotFoundException()

    private fun cancelActiveBookings(clientId: UUID, now: Instant) {
        val activeBookings = bookingRepository.findByClientIdAndStatus(clientId, BookingEntity.STATUS_ACTIVE)
        for (booking in activeBookings) {
            val slot = slotRepository.findById(booking.slotId).orElseThrow { NotFoundException() }
            slot.freeSeats += 1
            if (booking.equipment == BookingEntity.EQUIPMENT_RENTAL) {
                slot.freeRentalEquipment += 1
            }
            slotRepository.save(slot)

            booking.status = BookingEntity.STATUS_CANCELLED
            booking.cancelledAt = now
            booking.cancellationReason = CANCELLATION_REASON_ACCOUNT_DELETED
            bookingRepository.save(booking)
        }
    }

    private fun revokeSessions(clientId: UUID, now: Instant) {
        authSessionRepository.findByClientIdAndRevokedAtIsNull(clientId).forEach { session ->
            session.revokedAt = now
            authSessionRepository.save(session)
        }
    }

    private fun anonymizeClient(client: ClientEntity, now: Instant) {
        client.name = null
        client.phone = anonymizedPhone(client.id)
        client.phoneAnonymized = true
        client.deletedAt = now
    }

    private fun anonymizedPhone(clientId: UUID): String {
        val digits = clientId.toString().replace("-", "").take(12)
        return "+9$digits"
    }

    companion object {
        private const val CANCELLATION_REASON_ACCOUNT_DELETED = "account_deleted"
    }
}
