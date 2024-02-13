package io.mustelidae.otter.lutrogale.web.domain.grant

import io.mustelidae.otter.lutrogale.common.Audit
import io.mustelidae.otter.lutrogale.web.domain.navigation.MenuNavigation
import io.mustelidae.otter.lutrogale.web.domain.user.User
import jakarta.persistence.Entity
import jakarta.persistence.FetchType
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.JoinColumn
import jakarta.persistence.ManyToOne
import jakarta.persistence.Table

/**
 * Created by seooseok on 2016. 10. 5..
 */
@Entity
@Table(name = "UserHasMenuNavigation")
class UserPersonalGrant : Audit() {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null
        private set

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "userId", nullable = false, updatable = false)
    var user: User? = null
        private set

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "menuNavigationId", nullable = false, updatable = false)
    var menuNavigation: MenuNavigation? = null
        private set

    var status = true

    fun setBy(user: User) {
        this.user = user
        if (user.userPersonalGrants.contains(this).not()) {
            user.addBy(this)
        }
    }

    fun setBy(menuNavigation: MenuNavigation) {
        this.menuNavigation = menuNavigation
        if (menuNavigation.userPersonalGrants.contains(this).not()) {
            menuNavigation.addBy(this)
        }
    }

    fun expire() {
        status = false
    }
}
