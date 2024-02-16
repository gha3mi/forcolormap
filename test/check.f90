! The MIT License (MIT)
!
! Copyright (c) 2023-2024 Vincent Magnin
!
! Permission is hereby granted, free of charge, to any person obtaining a copy
! of this software and associated documentation files (the "Software"), to deal
! in the Software without restriction, including without limitation the rights
! to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
! copies of the Software, and to permit persons to whom the Software is
! furnished to do so, subject to the following conditions:
!
! The above copyright notice and this permission notice shall be included in all
! copies or substantial portions of the Software.
!
! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
! IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
! FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
! AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
! LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
! OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
! SOFTWARE.
!-------------------------------------------------------------------------------
! Contributed by vmagnin: 2023-10-19
! Last modification: vmagnin 2024-02-12
!-------------------------------------------------------------------------------

program check
    use forcolormap

    implicit none
    type(Colormap) :: cmap
    integer :: red, green, blue
    integer, dimension(0:6, 3) :: test_colormap = reshape( [ &
        1, 2, 3, &
        4, 5, 6, &
        7, 8, 9, &
        0, 0, 0, &
        9, 8, 7, &
        6, 5, 4, &
        3, 2, 1 ], &
        shape(test_colormap), order = [2, 1] )
    integer, dimension(0:6, 3) :: copy_colormap
    integer :: i

    call cmap%create("discrete", 0.0_wp, 2.0_wp, test_colormap)
    copy_colormap = test_colormap

    if (cmap%get_levels() /= 7)    error stop "ERROR: colormap%get_levels()"
    if (cmap%get_zmin() /= 0.0_wp) error stop "ERROR: colormap%get_zmin()"
    if (cmap%get_zmax() /= 2.0_wp) error stop "ERROR: colormap%get_zmax()"
    if (trim(cmap%get_name()) /= "discrete") error stop "ERROR: colormap%get_current()"

    do i = 0, size(test_colormap(:, 1))-1
        call cmap%get_RGB(i, red, green, blue)
        if ((red /= test_colormap(i, 1)).or.(green /= test_colormap(i, 2)) &
            & .or.(blue /= test_colormap(i, 3))) error stop "ERROR: colormap%get_RGB()"
    end do

    call cmap%compute_RGB(0.0_wp, red, green, blue)
    if ((red /= test_colormap(0, 1)).or.(green /= test_colormap(0, 2)) &
            & .or.(blue /= test_colormap(0, 3))) error stop "ERROR: colormap%compute_RGB()"
    call cmap%compute_RGB(1.1_wp, red, green, blue)
    if ((red /= test_colormap(3, 1)).or.(green /= test_colormap(3, 2)) &
            & .or.(blue /= test_colormap(3, 3))) error stop "ERROR: colormap%compute_RGB()"
    call cmap%compute_RGB(2.0_wp, red, green, blue)
    if ((red /= test_colormap(6, 1)).or.(green /= test_colormap(6, 2)) &
            & .or.(blue /= test_colormap(6, 3))) error stop "ERROR: colormap%compute_RGB()"

    !! Test the shift() method:
    call cmap%shift(+2)         ! Toward left
    call cmap%get_RGB(0, red, green, blue)
    if ((red /= copy_colormap(2, 1)).or.(green /= copy_colormap(2, 2)) &
        & .or.(blue /= copy_colormap(2, 3))) error stop "ERROR: colormap%shift()"
    call cmap%shift(-1)         ! Toward right
    call cmap%get_RGB(6, red, green, blue)
    if ((red /= copy_colormap(0, 1)).or.(green /= copy_colormap(0, 2)) &
        & .or.(blue /= copy_colormap(0, 3))) error stop "ERROR: colormap%shift()"

    !! Test check() procedure within set() procedure
    ! Name is not in the list
    call cmap%set('actom10', 0.0_wp, 2.0_wp)
    if (cmap%get_name() /= 'grayC') error stop "ERROR: colormap%check() name"
    
    ! Maximum value is less than minimum value
    call cmap%set('acton10', 2.0_wp, 0.0_wp)
    if (cmap%get_zmin() /= 0.0_wp .or. cmap%get_zmax() /= 2.0_wp) error stop "ERROR: colormap%check() zmin > zmax"
    
    ! Number of levels is not equal to predefined number of levels
    call cmap%set('acton10', 0.0_wp, 2.0_wp, 256)
    if (cmap%get_levels() /= 10) error stop "ERROR: colormap%check() levels /= predefined levels"


    !! Test check() procedure within create() procedure
    ! Maximum value is less than minimum value
    call cmap%create("discrete", 2.0_wp, 0.0_wp, test_colormap)
    if (cmap%get_zmin() /= 0.0_wp .or. cmap%get_zmax() /= 2.0_wp) error stop "ERROR: colormap%check() zmin > zmax"

end program check
