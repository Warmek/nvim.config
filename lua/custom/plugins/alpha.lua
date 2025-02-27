return {
    'goolord/alpha-nvim',
    config = function ()
        local alpha = require'alpha'
        local dashboard = require'alpha.themes.dashboard'

        dashboard.section.header.val = {
            [[*@@@m   *@@@*                   *@@@@*   *@@@**@@@@**@@@@m     m@@@*]],
            [[  @@@m    @                       *@@     m@    @@    @@@@    @@@@  ]],
            [[  @ @@@   @    mm@*@@   m@@*@@m    @@m   m@     @@    @ @@   m@ @@  ]],
            [[  @  *@@m @   m@*   @@ @@*   *@@    @@m  @*     @@    @  @!  @* @@  ]],
            [[  @   *@@m!   !@****** @@     @@    *!@ !*      @!    !  @!m@*  @@  ]],
            [[  !     !@!   !@m    m @@     !@     !@@m       @!    !  *!@*   @@  ]],
            [[  !   *!!!!   !!****** !@     !!     !! !*      !!    !  !!!!*  !!  ]],
            [[  !     !!!   :!!      !!!   !!!     !!::       :!    :  *!!*   !!  ]],
            [[: : :    :!!   : : ::   : : : :       :       :!: : : ::: :   : ::: ]],
        }

        dashboard.section.buttons.val = {
             dashboard.button( "e", "  New file" , ":ene <BAR> startinsert <CR>"),
             dashboard.button( "q", "  Quit NVIM" , ":qa<CR>"),
         }


        alpha.setup(dashboard.config)
    end
};
