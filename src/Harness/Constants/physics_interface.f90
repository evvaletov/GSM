!==============================================================================
!> Physical constants interface
!>
!> Provides an interface to arrayed constants for consumer protection
!>
!==============================================================================

    !> Interface to return the value of A^(1/3)
    !>
    !> Interface function for allowing consumers to obtain A^(1/3). This
    !> wrapper provides additional protection to ensure input parameters are not
    !> out of bounds for the internal structure.
    function ato3rd_interface(A) result(val)
       !> The mass number, A, being requested.
       integer(int16), intent(in) :: A

       !> The value of A^(1/3).
       real(real64) :: val

       if (A < 1) then
          write (error_unit, *) "Cannot have a mass number of 0 or less."
          error stop
       end if
       if (A > largest_mass_number) then
          write (error_unit, *) "Cannot have atomic number greater than 300."
          error stop
       end if
       val = ato3rd_int(A)
       return
    end function ato3rd_interface

    !> Allocates the nuclear charge radius data
    !>
    !> Subroutine to set the values of the nuclear charge radius from I. Angeli,
    !> Atomic Data and Nuclear Data tables, 99(1), (2013), 69.
    !>
    !> Used in NASA cross section calculations
    !> Note: if the data was already allocated, it will not be allocated again.
    !>
    !> Initially implemented by Leslie M. Kerby, 07/2014, LANL.
    subroutine assign_r_rms()
       !> Approximate r_0 value [fm]; varies by up to 0.2 fm.
       real(real64), parameter :: r0 = 1.25

       integer(int8) :: iZ
       integer(int16) :: iA

       if (.not. allocated(r_rms_internal)) then
          ! Allociate memory for the internal charge radius
          allocate ( &
              & r_rms_internal(largest_atomic_number, largest_mass_number) &
              & )

          ! Approximate values
          do iZ = 1, largest_atomic_number
             do iA = 1, largest_mass_number
                r_rms_internal(iZ, iA) = r0*ato3rd_interface(iA)
             end do
          end do

          ! For nuclei with experimental data
          r_rms_internal(1, 1) = 0.85                ! n (use 1987 proton radius) (not -0.1149 as listed in angeli) (and not 0.34 as listed in devries 1987)
          r_rms_internal(2, 1:3) = (/0.8783, 2.1421, 1.7591/)    ! h
          r_rms_internal(3, 3:4) = (/1.9661, 1.6755/)        ! he
          r_rms_internal(3, 6) = 2.0660
          r_rms_internal(3, 8) = 1.9239
          r_rms_internal(4, 6:9) = (/2.5890, 2.4440, 2.3390, 2.2450/)        ! li
          r_rms_internal(4, 11) = 2.4820
          r_rms_internal(5, 7) = 2.6460                ! be
          r_rms_internal(5, 9:11) = (/2.5190, 2.3550, 2.4630/)
          r_rms_internal(6, 10:11) = (/2.4277, 2.4060/)        ! b
          r_rms_internal(7, 12:14) = (/2.4702, 2.4614, 2.5025/)    ! c
          r_rms_internal(8, 14:15) = (/2.5582, 2.6058/)        ! n
          r_rms_internal(9, 16:18) = (/2.6991, 2.6932, 2.7726/)    ! o
          r_rms_internal(10, 19) = 2.8976                ! f
          r_rms_internal(11, 17:26) = (/3.0413, 2.9714, 3.0082, 3.0055, &
              & 2.9695, 2.9525, 2.9104, 2.9007, 2.9316, 2.9251/)    ! ne
          r_rms_internal(11, 28) = 2.9642
          r_rms_internal(12, 20:31) = (/2.9718, 3.0136, 2.9852, 2.9936, &
              & 2.9735, 2.9769, 2.9928, 3.0136, 3.0400, 3.0922, 3.1180, 3.1704/)    ! na
          r_rms_internal(13, 24:26) = (/3.0570, 3.0284, 3.0337/)    ! mg
          r_rms_internal(14, 27) = 3.0610                 ! al
          r_rms_internal(15, 28:30) = (/3.1224, 3.1176, 3.1336/)    ! si
          r_rms_internal(16, 31) = 3.1889                    ! p
          r_rms_internal(17, 32) = 3.2611                    ! s
          r_rms_internal(17, 34) = 3.2847
          r_rms_internal(17, 36) = 3.2985
          r_rms_internal(18, 35) = 3.3654                    ! cl
          r_rms_internal(18, 37) = 3.3840
          r_rms_internal(19, 32:44) = (/3.3468, 3.3438, 3.3654, 3.3636, &
              & 3.3905, 3.3908, 3.4028, 3.4093, 3.4274, 3.4251, 3.4354, &    ! ar
              & 3.4414, 3.4454/)
          r_rms_internal(19, 46) = 3.4377
          r_rms_internal(20, 38:47) = (/3.4264, 3.4349, 3.4381, 3.4518, &
              & 3.4517, 3.4556, 3.4563, 3.4605, 3.4558, 3.4534/)    ! k
          r_rms_internal(21, 39:48) = (/3.4595, 3.4776, 3.4780, 3.5081, &
              & 3.4954, 3.5179, 3.4944, 3.4953, 3.4783, 3.4771/)        ! ca
          r_rms_internal(21, 50) = 3.5168
          r_rms_internal(22, 42:46) = (/3.5702, 3.5575, 3.5432, 3.5459, 3.5243/)        ! sc
          r_rms_internal(23, 44:50) = (/3.6115, 3.5939, 3.6070, 3.5962, &
              & 3.5921, 3.5733, 3.5704/)        ! ti
          r_rms_internal(24, 51) = 3.6002                    ! v
          r_rms_internal(25, 50) = 3.6588                    ! cr
          r_rms_internal(25, 52:54) = (/3.6452, 3.6511, 3.6885/)
          r_rms_internal(26, 50:56) = (/3.7120, 3.7026, 3.6706, 3.6662, &
              & 3.6834, 3.7057, 3.7146/)        ! mn
          r_rms_internal(27, 54) = 3.6933                    ! fe
          r_rms_internal(27, 56:58) = (/3.7377, 3.7532, 3.7745/)
          r_rms_internal(28, 59) = 3.7875                    ! co
          r_rms_internal(29, 58) = 3.7757                    ! ni
          r_rms_internal(29, 60:62) = (/3.8118, 3.8225, 3.8399/)
          r_rms_internal(29, 64) = 3.8572
          r_rms_internal(30, 63) = 3.8823                    ! cu
          r_rms_internal(30, 65) = 3.9022
          r_rms_internal(31, 64) = 3.9283                    ! zn
          r_rms_internal(31, 66:68) = (/3.9491, 3.9530, 3.9658/)
          r_rms_internal(31, 70) = 3.9845
          r_rms_internal(32, 69) = 3.9973                    ! ga
          r_rms_internal(32, 71) = 4.0118
          r_rms_internal(33, 70) = 4.0414                    ! ge
          r_rms_internal(33, 72:74) = (/4.0576, 4.0632, 4.0742/)
          r_rms_internal(33, 76) = 4.0811
          r_rms_internal(34, 75) = 4.0968                    ! as
          r_rms_internal(35, 74) = 4.0700                    ! se
          r_rms_internal(35, 76:78) = (/4.1395, 4.1395, 4.1406/)
          r_rms_internal(35, 80) = 4.1400
          r_rms_internal(35, 82) = 4.1400
          r_rms_internal(36, 79) = 4.1629                    ! br
          r_rms_internal(36, 81) = 4.1599
          r_rms_internal(37, 72) = 4.1635                    ! kr
          r_rms_internal(37, 74:96) = (/4.1870, 4.2097, 4.2020, 4.2082, &
              & 4.2038, 4.2034, 4.1970, 4.1952, 4.1919, 4.1871, 4.1884, &
              & 4.1846, 4.1835, 4.1984, 4.2171, 4.2286, 4.2423, 4.2543, &
              & 4.2724, 4.2794, 4.3002, 4.3067, 4.3267/)
          r_rms_internal(38, 76:98) = (/4.2273, 4.2356, 4.2385, 4.2284, &
              & 4.2271, 4.2213, 4.2160, 4.2058, 4.1999, 4.2036, 4.2025, &     ! rb
              & 4.1989, 4.2170, 4.2391, 4.2554, 4.2723, 4.2903, 4.3048, &
              & 4.3184, 4.3391, 4.3501, 4.4231, 4.4336/)
          r_rms_internal(39, 77:100) = (/4.2569, 4.2561, 4.2586, 4.2562, &
              & 4.2547, 4.2478, 4.2455, 4.2394, 4.2304, 4.2307, 4.2249, &    ! sr
              & 4.2240, 4.2407, 4.2611, 4.2740, 4.2924, 4.3026, 4.3191, &
              & 4.3305, 4.3522, 4.3625, 4.4377, 4.4495, 4.4640/)
          r_rms_internal(40, 86:90) = (/4.2513, 4.2498, 4.2441, 4.2430, &
              & 4.2573/)        ! y
          r_rms_internal(40, 92:102) = (/4.2887, 4.3052, 4.3142, 4.3284, &
              & 4.3402, 4.3580, 4.3711, 4.4658, 4.4705, 4.4863, 4.4911/)
          r_rms_internal(41, 87:92) = (/4.2789, 4.2787, 4.2706, 4.2694, &
              & 4.2845, 4.3057/)    ! zr
          r_rms_internal(41, 94) = 4.3320
          r_rms_internal(41, 96:102) = (/4.3512, 4.3792, 4.4012, 4.4156, &
              & 4.4891, 4.5119, 4.5292/)
          r_rms_internal(42, 90:93) = (/4.2891, 4.2878, 4.3026, 4.3240/)            ! nb
          r_rms_internal(42, 99) = 4.4062
          r_rms_internal(42, 101) = 4.4861
          r_rms_internal(42, 103) = 4.5097
          r_rms_internal(43, 90:92) = (/4.3265, 4.3182, 4.3151/)            ! mo
          r_rms_internal(43, 94:98) = (/4.3529, 4.3628, 4.3847, 4.3880, &
              & 4.4091/)
          r_rms_internal(43, 100) = 4.4468
          r_rms_internal(43, 102:106) = (/4.4914, 4.5145, 4.5249, 4.5389, &
              & 4.5490/)
          r_rms_internal(43, 108) = 4.5602
          ! No Z=43 (Tc, Technetium--no stable isotopes)
          r_rms_internal(45, 96) = 4.3908                    ! ru
          r_rms_internal(45, 98:102) = (/4.4229, 4.4338, 4.4531, 4.4606, &
              & 4.4809/)
          r_rms_internal(45, 104) = 4.5098
          r_rms_internal(46, 103) = 4.4945                ! rh
          r_rms_internal(47, 102) = 4.4827                ! pd
          r_rms_internal(47, 104:106) = (/4.5078, 4.5150, 4.5318/)
          r_rms_internal(47, 108) = 4.5563
          r_rms_internal(47, 110) = 4.5782
          r_rms_internal(48, 101) = 4.4799                ! ag
          r_rms_internal(48, 103:105) = (/4.5036, 4.5119, 4.5269/)
          r_rms_internal(48, 107) = 4.5454
          r_rms_internal(48, 109) = 4.5638
          r_rms_internal(49, 102:118) = (/4.4810, 4.4951, 4.5122, 4.5216, &
              & 4.5383, 4.5466, 4.5577, 4.5601, 4.5765, 4.5845, 4.5944, &    ! cd
              & 4.6012, 4.6087, 4.6114, 4.6203, 4.6136, 4.6246/)
          r_rms_internal(49, 120) = 4.6300
          r_rms_internal(50, 104:127) = (/4.5184, 4.5311, 4.5375, 4.5494, &
              & 4.5571, 4.5685, 4.5742, 4.5856, 4.5907, 4.6010, 4.6056, &    ! in
              & 4.6156, 4.6211, 4.6292, 4.6335, 4.6407, 4.6443, 4.6505, &
              & 4.6534, 4.6594, 4.6625, 4.6670, 4.6702, 4.6733/)
          r_rms_internal(51, 108:132) = (/4.5605, 4.5679, 4.5785, 4.5836, &
              & 4.5948, 4.6015, 4.6099, 4.6148, 4.6250, 4.6302, 4.6393, &    ! sn
              & 4.6438, 4.6519, 4.6566, 4.6634, 4.6665, 4.6735, 4.6765, &
              & 4.6833, 4.6867, 4.6921, 4.6934, 4.7019, 4.7078, 4.7093/)
          r_rms_internal(52, 121) = 4.6802                ! sb
          r_rms_internal(52, 123) = 4.6879
          r_rms_internal(53, 116) = 4.6847                ! te
          r_rms_internal(53, 118) = 4.6956
          r_rms_internal(53, 120) = 4.7038
          r_rms_internal(53, 122:126) = (/4.7095, 4.7117, 4.7183, 4.7204, &
              & 4.7266/)
          r_rms_internal(53, 128) = 4.7346
          r_rms_internal(53, 130) = 4.7423
          r_rms_internal(53, 132) = 4.7500
          r_rms_internal(53, 134) = 4.7569
          r_rms_internal(53, 136) = 4.7815
          r_rms_internal(54, 127) = 4.7500                ! i
          r_rms_internal(55, 116) = 4.7211                ! xe
          r_rms_internal(55, 118) = 4.7387
          r_rms_internal(55, 120) = 4.7509
          r_rms_internal(55, 122) = 4.7590
          r_rms_internal(55, 124) = 4.7661
          r_rms_internal(55, 126:134) = (/4.7722, 4.7747, 4.7774, 4.7775, &
              & 4.7818, 4.7808, 4.7859, 4.7831, 4.7899/)
          r_rms_internal(55, 136:144) = (/4.7964, 4.8094, 4.8279, 4.8409, &
              & 4.8566, 4.8694, 4.8841, 4.8942, 4.9082/)
          r_rms_internal(55, 146) = 4.9315
          r_rms_internal(56, 118:146) = (/4.7832, 4.7896, 4.7915, 4.7769, &
              & 4.7773, 4.7820, 4.7828, 4.7880, 4.7872, 4.7936, 4.7921, &    ! cs
              & 4.7981, 4.7992, 4.8026, 4.8002, 4.8041, 4.8031, 4.8067, &
              & 4.8059, 4.8128, 4.8255, 4.8422, 4.8554, &
              & 4.8689, 4.8825, 4.8965, 4.9055, 4.9188, 4.9281/)
          r_rms_internal(57, 120:146) = (/4.8092, 4.8176, 4.8153, 4.8135, &
              & 4.8185, 4.8177, 4.8221, 4.8204, 4.8255, 4.8248, 4.8283, &    ! ba
              & 4.8276, 4.8303, 4.8286, 4.8322, 4.8294, 4.8334, 4.8314, &
              & 4.8378, 4.8513, 4.8684, 4.8807, 4.8953, &
              & 4.9087, 4.9236, 4.9345, 4.9479/)
          r_rms_internal(57, 148) = 4.9731
          r_rms_internal(58, 135) = 4.8488                ! la
          r_rms_internal(58, 137:139) = (/4.8496, 4.8473, 4.8550/)
          r_rms_internal(59, 136) = 4.8739                ! ce
          r_rms_internal(59, 138) = 4.8737
          r_rms_internal(59, 140) = 4.8771
          r_rms_internal(59, 142) = 4.9063
          r_rms_internal(59, 144) = 4.9303
          r_rms_internal(59, 146) = 4.9590
          r_rms_internal(59, 148) = 4.9893
          r_rms_internal(60, 141) = 4.8919                ! pr
          r_rms_internal(61, 132) = 4.9174                ! nd
          r_rms_internal(61, 134:146) = (/4.9128, 4.9086, 4.9111, 4.9080, &
              & 4.9123, 4.9076, 4.9101, 4.9057, 4.9123, 4.9254, 4.9421, &
              & 4.9535, 4.9696/)
          r_rms_internal(61, 148) = 4.9999
          r_rms_internal(61, 150) = 5.0400
          ! No Z=61 (Pm, Promethium)
          r_rms_internal(63, 138:154) = (/4.9599, 4.9556, 4.9565, 4.9517, &
              & 4.9518, 4.9479, 4.9524, 4.9651, 4.9808, 4.9892, 5.0042, &    ! sm
              & 5.0134, 5.0387, 5.0550, 5.0819, 5.0925, 5.1053/)
          r_rms_internal(64, 137:159) = (/4.9762, 4.9779, 4.9760, 4.9695, &
              & 4.9697, 4.9607, 4.9636, 4.9612, 4.9663, 4.9789, 4.9938, &    ! eu
              & 5.0045, 5.0202, 5.0296, 5.052, 5.10645, 5.1115, 5.1239, &
              & 5.1221, 5.1264, 5.1351, 5.1413, 5.1498/)
          r_rms_internal(65, 145:146) = (/4.9786, 4.9801/)        ! gd
          r_rms_internal(65, 148) = 5.0080
          r_rms_internal(65, 150) = 5.0342
          r_rms_internal(65, 152) = 5.0774
          r_rms_internal(65, 154:158) = (/5.1223, 5.1319, 5.1420, 5.1449, &
              & 5.1569/)
          r_rms_internal(65, 160) = 5.1734
          r_rms_internal(66, 147:155) = (/4.9201, 4.9291, 4.9427, 4.9499, &
              & 4.9630, 4.9689, 4.9950, 5.0333, 5.0391/)        ! tb
          r_rms_internal(66, 157) = 5.0489
          r_rms_internal(66, 159) = 5.0600
          r_rms_internal(67, 146) = 5.0438                ! dy
          r_rms_internal(67, 148:164) = (/5.0455, 5.0567, 5.0706, 5.0801, &
              & 5.0950, 5.1035, 5.1241, 5.1457, 5.1622, 5.1709, 5.1815, &
              & 5.1825, 5.1951, 5.1962, 5.2074, 5.2099, 5.2218/)
          r_rms_internal(68, 151:163) = (/5.0398, 5.0614, 5.0760, 5.0856, &
              & 5.1076, 5.1156, 5.1535, 5.1571, 5.1675, 5.1662, 5.1785, &    ! ho
              & 5.1817, 5.1907/)
          r_rms_internal(68, 165) = 5.2022
          r_rms_internal(69, 150) = 5.0548                ! er
          r_rms_internal(69, 152) = 5.0843
          r_rms_internal(69, 154) = 5.1129
          r_rms_internal(69, 156) = 5.1429
          r_rms_internal(69, 158) = 5.1761
          r_rms_internal(69, 160) = 5.2045
          r_rms_internal(69, 162) = 5.2246
          r_rms_internal(69, 164) = 5.2389
          r_rms_internal(69, 166:168) = (/5.2516, 5.2560, 5.2644/)
          r_rms_internal(69, 170) = 5.2789
          r_rms_internal(70, 153:154) = (/5.0643, 5.0755/)        ! tm
          r_rms_internal(70, 156:172) = (/5.0976, 5.1140, 5.1235, 5.1392, &
              & 5.1504, 5.1616, 5.1713, 5.1849, 5.1906, 5.2004, 5.2046, &
              & 5.2129, 5.2170, 5.2256, 5.2303, 5.2388, 5.2411/)
          r_rms_internal(71, 152) = 5.0423                ! yb
          r_rms_internal(71, 154:176) = (/5.0875, 5.1040, 5.1219, 5.1324, &
              & 5.1498, 5.1629, 5.1781, 5.1889, 5.2054, 5.2157, 5.2307, &
              & 5.2399, 5.2525, 5.2621, 5.2702, 5.2771, 5.2853, 5.2906, &
              & 5.2995, 5.3046, 5.3108, 5.3135, 5.3215/)
          r_rms_internal(72, 161:179) = (/5.2293, 5.2398, 5.2567, 5.2677, &
              & 5.2830, 5.2972, 5.3108, 5.3227, 5.3290, 5.3364, 5.3436, &    ! lu
              & 5.3486, 5.3577, 5.3634, 5.3700, 5.3739, 5.3815, 5.3857, &
              & 5.3917/)
          r_rms_internal(73, 170:180) = (/5.2898, 5.3041, 5.3065, 5.3140, &
              & 5.3201, 5.3191, 5.3286, 5.3309, 5.3371, 5.3408, 5.3470/)    ! hf
          r_rms_internal(73, 182) = 5.3516
          r_rms_internal(74, 181) = 5.3507                ! ta
          r_rms_internal(75, 180) = 5.3491                ! w
          r_rms_internal(75, 182:184) = (/5.3559, 5.3611, 5.3658/)
          r_rms_internal(75, 186) = 5.3743
          r_rms_internal(76, 185) = 5.3596                ! re
          r_rms_internal(76, 187) = 5.3698
          r_rms_internal(77, 184) = 5.3823                ! os
          r_rms_internal(77, 186:190) = (/5.3909, 5.3933, 5.3993, 5.4016, &
              & 5.4062/)
          r_rms_internal(77, 192) = 5.4126
          r_rms_internal(78, 182:189) = (/5.3705, 5.3780, 5.3805, 5.3854, &
              & 5.3900, 5.3812, 5.3838, 5.3898/)        ! ir
          r_rms_internal(78, 191) = 5.3968
          r_rms_internal(78, 193) = 5.4032
          r_rms_internal(79, 178:196) = (/5.3728, 5.3915, 5.3891, 5.3996, &
              & 5.3969, 5.4038, 5.4015, 5.4148, 5.4037, 5.4063, 5.4053, &    ! pt
              & 5.4060, 5.4108, 5.4102, 5.4169, 5.4191, 5.4236, 5.4270, &
              & 5.4307/)
          r_rms_internal(79, 198) = 5.4383
          r_rms_internal(80, 183:199) = (/5.4247, 5.4306, 5.4296, 5.4354, &
              & 5.4018, 5.4049, 5.4084, 5.4109, 5.4147, 5.4179, 5.4221, &    ! au
              & 5.4252, 5.4298, 5.4332, 5.4371, 5.4400, 5.4454/)
          r_rms_internal(81, 181:206) = (/5.4364, 5.3833, 5.4405, 5.3949, &
              & 5.4397, 5.4017, 5.4046, 5.4085, 5.4100, 5.4158, 5.4171, &    ! hg
              & 5.4232, 5.4238, 5.4309, 5.4345, 5.4385, 5.4412, 5.4463, &
              & 5.4474, 5.4551, 5.4581, 5.4648, 5.4679, 5.4744, 5.4776, &
              & 5.4837/)
          r_rms_internal(82, 188) = 5.4017                                        ! tl
          r_rms_internal(82, 190:205) = (/5.4121, 5.4169, 5.4191, 5.4243, &
              & 5.4259, 5.4325, 5.4327, 5.4388, 5.4396, 5.4479, &
              & 5.4491, 5.4573, 5.4595, 5.4666, 5.4704, 5.4759/)
          r_rms_internal(82, 207) = 5.4853
          r_rms_internal(82, 208) = 5.4946
          r_rms_internal(83, 182:212) = (/5.3788, 5.3869, 5.3930, 5.3984, &
              & 5.4027, 5.4079, 5.4139, 5.4177, 5.4222, 5.4229, 5.4300, &    ! pb
              & 5.4310, 5.4372, 5.4389, 5.4444, 5.4446, 5.4524, 5.4529, &
              & 5.4611, 5.4629, 5.4705, 5.4727, 5.4803, 5.4828, 5.4902, &
              & 5.4943, 5.5011, 5.5100, 5.5208, 5.5290, 5.5396/)
          r_rms_internal(83, 214) = 5.5577
          r_rms_internal(84, 202:210) = (/5.4840, 5.4911, 5.4934, 5.5008, &
              & 5.5034, 5.5103, 5.5147, 5.5211, 5.5300/)            ! bi
          r_rms_internal(84, 212:213) = (/5.5489, 5.5586/)
          r_rms_internal(85, 192) = 5.5220                ! po
          r_rms_internal(85, 194) = 5.5167
          r_rms_internal(85, 196) = 5.5136
          r_rms_internal(85, 198) = 5.5146
          r_rms_internal(85, 200) = 5.5199
          r_rms_internal(85, 202) = 5.5281
          r_rms_internal(85, 204:210) = (/5.5378, 5.5389, 5.5480, 5.5501, &
              & 5.5584, 5.5628, 5.5704/)
          r_rms_internal(85, 216) = 5.6359
          r_rms_internal(85, 218) = 5.6558
          ! No Z=85 (At, Astatine)
          r_rms_internal(87, 202) = 5.5521                ! rn
          r_rms_internal(87, 204:212) = (/5.5568, 5.5569, 5.5640, 5.5652, &
              & 5.5725, 5.5743, 5.5813, 5.5850, 5.5915/)
          r_rms_internal(87, 218:222) = (/5.6540, 5.6648, 5.6731, 5.6834, &
              & 5.6915/)
          r_rms_internal(88, 207:213) = (/5.5720, 5.5729, 5.5799, 5.5818, &
              & 5.5882, 5.5915, 5.5977/)                    ! fr
          r_rms_internal(88, 220:228) = (/5.6688, 5.6790, 5.6890, 5.6951, &
              & 5.7061, 5.7112, 5.7190, 5.7335, 5.7399/)
          r_rms_internal(89, 208:214) = (/5.5850, 5.5853, 5.5917, 5.5929, &
              & 5.5991, 5.6020, 5.6079/)                    ! ra
          r_rms_internal(89, 220:230) = (/5.6683, 5.6795, 5.6874, 5.6973, &
              & 5.7046, 5.7150, 5.7211, 5.7283, 5.7370, 5.7455, 5.7551/)
          r_rms_internal(89, 232) = 5.7714
          ! No Z=89 (Ac, Actinium)
          r_rms_internal(91, 227:230) = (/5.7404, 5.7488, 5.7557, 5.7670/)                                ! th
          r_rms_internal(91, 232) = 5.7848
          ! No Z=91 (Pa, Protactinium)
          r_rms_internal(93, 233:236) = (/5.8203, 5.8291, 5.8337, 5.8431/)                                ! u
          r_rms_internal(93, 238) = 5.8571
          ! No Z=93 (Np, Neptunium)
          r_rms_internal(95, 238:242) = (/5.8535, 5.8601, 5.8701, 5.8748, &
              & 5.8823/)
          r_rms_internal(95, 244) = 5.8948
          r_rms_internal(96, 241) = 5.8928                ! am
          r_rms_internal(96, 243) = 5.9048
          r_rms_internal(97, 242) = 5.8285                ! cm
          r_rms_internal(97, 244:246) = (/5.8429, 5.8475, 5.8562/)
          r_rms_internal(97, 248) = 5.8687
       end if
    end subroutine assign_r_rms

    !> Interface to return the nuclear charge radius [fm]
    !>
    !> Interface function to return the nuclear charge radius of a nucleus.
    !> Access data via r_rms_internal(Z + 1, A) for a nucleus.
    !> Limits are Z <= 99, A <= 300: r_rms_internal(100, 300)
    function r_rms_interface(Zp1, A) result(val)
       !> Nucleus's Z value plus one (Z + 1)
       integer(int8), intent(in) :: Zp1
       !> Nucleus's A number
       integer(int16), intent(in) :: A
       !> Returned nuclear charge radius
       real(real64) :: val

       ! Ensure data has been allocated
       if (.not. allocated(r_rms_internal)) then
          call assign_r_rms()
       end if

       ! Validate limits
       if (Zp1 < 1 .or. Zp1 > largest_atomic_number) then
          write (error_unit, *) "Invalid Z number for nuclear charge radius: ", Zp1
          error stop
       end if
       if (A < 0 .or. A > largest_mass_number) then
          write (error_unit, *) "Invalid A number for nuclear charge radius: ", A
       end if

       val = r_rms_internal(Zp1, A)
       return
    end function r_rms_interface

