package io.mustelidae.otter.lutrogale.api.domain.migration.openapi

import io.kotest.matchers.shouldBe
import io.mockk.every
import io.mockk.mockk
import io.mustelidae.otter.lutrogale.api.domain.migration.PathToMenu
import io.mustelidae.otter.lutrogale.web.domain.navigation.MenuNavigation
import io.mustelidae.otter.lutrogale.web.domain.navigation.repository.MenuNavigationRepository
import io.mustelidae.otter.lutrogale.web.domain.project.Project
import org.junit.jupiter.api.Test
import org.springframework.web.bind.annotation.RequestMethod

class FlatBasePathToMenuTest {

    @Test
    fun makeCode() {
        val specs = listOf(
            HttpAPISpec("/sample/:id", listOf(RequestMethod.GET), "sample"),
            HttpAPISpec("/sample/hello/:id", listOf(RequestMethod.POST, RequestMethod.GET), "sample hello"),
            HttpAPISpec("/sample/hello/world/:id", listOf(RequestMethod.POST, RequestMethod.GET), "sample hello world"),
            HttpAPISpec("/never/:id", listOf(RequestMethod.GET, RequestMethod.POST), "never"),
            HttpAPISpec("/never/:id/die", listOf(RequestMethod.POST, RequestMethod.GET, RequestMethod.PUT), "never die"),
            HttpAPISpec("/A/:a/B/C/D/:d", listOf(RequestMethod.POST), "ABCD"),
            HttpAPISpec("/A/:a/B/C/:c/D/:d", listOf(RequestMethod.POST, RequestMethod.GET, RequestMethod.PUT), "ABCD"),
        )

        val root = MenuNavigation.root().apply {
            setBy(Project("migration", null, ""))
        }

        val menuNavigationRepository: MenuNavigationRepository = mockk()
        every { menuNavigationRepository.save(any()) } returns MenuNavigation.root()
        val pathToMenu: PathToMenu = FlatBasePathToMenu(specs, root)

        pathToMenu.makeTree(menuNavigationRepository)

        println(pathToMenu.printMenuTree())

        pathToMenu.rootMenuNavigation.menuNavigations.size shouldBe 14
    }
}
