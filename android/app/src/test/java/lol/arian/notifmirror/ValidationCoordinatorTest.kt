package br.mol.net.br

import android.app.NotificationManager
import android.content.Context
import androidx.test.core.app.ApplicationProvider
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [30])
class ValidationCoordinatorTest {
    private val context: Context = ApplicationProvider.getApplicationContext()
    private val mgr: NotificationManager
        get() = context.getSystemService(NotificationManager::class.java)

    @Before
    fun setUp() {
        ValidationCoordinator.disarm()
        mgr.cancelAll()
    }

    @After
    fun tearDown() {
        ValidationCoordinator.disarm()
        mgr.cancelAll()
    }

    @Test
    fun post_arms_token_and_shows_notification() {
        val token = "MMV-TEST-001"
        ValidationCoordinator.postTestNotification(context, token)

        assertEquals(token, ValidationCoordinator.pending)
        assertTrue(ValidationCoordinator.matchesPendingEcho("Ntfy Mirror validation test — $token"))
        assertTrue(mgr.activeNotifications.isNotEmpty())
    }

    @Test
    fun matches_requires_exact_armed_token() {
        assertFalse(ValidationCoordinator.matchesPendingEcho("MMV-TEST-001"))

        ValidationCoordinator.arm("MMV-TEST-002")
        assertTrue(ValidationCoordinator.matchesPendingEcho("prefix MMV-TEST-002 suffix"))
        assertFalse(ValidationCoordinator.matchesPendingEcho("MMV-TEST-001"))
    }

    @Test
    fun cancel_disarms_and_clears_notification() {
        ValidationCoordinator.postTestNotification(context, "MMV-TEST-003")
        ValidationCoordinator.cancelTestNotification(context)

        assertNull(ValidationCoordinator.pending)
        assertFalse(ValidationCoordinator.matchesPendingEcho("MMV-TEST-003"))
        assertTrue(mgr.activeNotifications.isEmpty())
    }
}
