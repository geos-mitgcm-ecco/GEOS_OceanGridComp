subroutine reroute3(dstind, weight, slmask, ii, jj, &
     lons, lats, area, tnum, Nr, Nt, Nto, im, jm)
  implicit none
  integer, intent(inout) :: dstind(Nr)
  real, intent(inout) :: weight(Nr) ! New destination index in routing table
  real, intent(in)  :: slmask(jm,im) ! sea-land mask
  integer, intent(in)  :: ii(Nt), jj(Nt) ! indexes of ocean grid
  real, intent(in)  :: lons(Nt), lats(Nt), area(Nt)  ! lons and lats and area of tiles
  integer, intent(in) :: tnum(Nto) ! number of ocean tile in tile file
  integer, intent(in) :: Nr, Nt, Nto, im, jm
  real :: dist(Nto) ! distances to re-routed tile
  integer :: i, dind, tt, nmoved, dind0, ind0
  logical :: moveit

  !f2py intent(in) :: slmask, ii, jj, lons, lats, area, tnum
  !f2py intent(in,out) :: dstind, weight
  !f2py intent(hide) :: Nr, Nt, Nto, im, jm

  nmoved=0
  dind0=0
  ind0=0
  
  print *,'Sanity checks!'
  print *,'Sizes ii/jj', size(ii),size(jj)
  print *,'Sizes slmask', size(slmask,2), size(slmask,1)

  do i=1,Nr
     moveit = .false.
     dind=dstind(i)
     if (dind > Nt .or. dind < 1) then
        print *,'ERROR: dind=',dind,i
     end if
     if (ii(dind) > size(slmask,2)) then
        moveit = .true.
!        print *,'ERROR: ii=',ii(dind),i,dind
     end if
     if (jj(dind) > size(slmask,1)) then
        moveit = .true.
!        print *,'ERROR: jj=',jj(dind),i,dind
     end if
     if( .not. moveit) then
        if( slmask(jj(dind),ii(dind)) == 0) then
           moveit = .true.
        end if
     end if
     if(moveit) then
        nmoved=nmoved+1
        if (i > 1 .and. dind == dind0) then
          dstind(i)=dstind(ind0)
          weight(i)=weight(i)*area(dind)/area(dstind(ind0)) 
        else
          forall(tt=1:Nto) dist(tt)=((lats(dind)-lats(tnum(tt)))**2+(lons(dind)-lons(tnum(tt)))**2)
          dstind(i)=tnum(minloc(dist,1))
          weight(i)=weight(i)*area(dind)/area(dstind(i))  
        end if 
        dind0=dind
        ind0=i
        print*, 'Total tiles: ', Nr, ' Tile number: ', i, ' Moved ', nmoved 
     end if
  end do
  
  print*, 'Total tiles re-routed: ', nmoved
end subroutine reroute3


