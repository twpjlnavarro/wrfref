
; Example of using panels with WRF data

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
;--  a = addfile("../wrfout_d01_2000-01-24_12:00:00.nc","r")
  a = addfile("$HOME/out/wrfd01.nc","r")

; We generate plots, but what kind do we prefer?
  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
  wks = gsn_open_wks(type,"plt_panel2")


; Set some basic resources
  res = True
  res@NoHeaderFooter           = True            ; Switch headers and footers off
  res@pmLabelBarOrthogonalPosF = -0.1
  res@lbTitleOn = False

  pltres = True
  pltres@PanelPlot = True      ; Indicate these plots are to be paneled.
  mpres = True
  mpres3 = True
  ;mpres3@mpGeophysicalLineColor = "Black"
  ;mpres3@mpNationalLineColor    = "Black"
  ;mpres3@mpUSStateLineColor     = "Black"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; What times and how many time steps are in the data set?
  times = wrf_user_getvar(a,"times",-1)  ; get all times in the file
  ntimes = dimsizes(times)         ; number of times in the file

  plots = new ( 4, graphic )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  
;--  do it = 0,ntimes-1
  do it = 30,30

    print("Working on time: " + times(it) )
    res@TimeLabel = times(it)   ; Set Valid time to use on plots


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First get the variables we will need        

    slp = wrf_user_getvar(a,"slp",it)    ; slp
      wrf_smooth_2d( slp, 3 )            ; smooth slp
    if ( it .eq. 0 ) then                
      tc = wrf_user_getvar(a,"tc",it)    ; 3D tc 
      td = wrf_user_getvar(a,"td",it)    ; 3D td 
      u  = wrf_user_getvar(a,"ua",it)    ; 3D U at mass points
      v  = wrf_user_getvar(a,"va",it)    ; 3D V at mass points
      tc2 = tc(0,:,:)                    ; Use lowest T at time zero
      td2 = td(0,:,:)                    ; Use lowest Td at time zero
      u10 = u(0,:,:)                     ; Use lowest level at time 0
      v10 = v(0,:,:)
    else
      tc2 = wrf_user_getvar(a,"T2",it)   ; T2 in Kelvin
         tc2 = tc2-273.16                  ; T2 in C
      td2 =  wrf_user_getvar(a,"td2",it) ; Td2 in C
      u10 = wrf_user_getvar(a,"U10",it)  ; u at 10 m, mass point
      v10 = wrf_user_getvar(a,"V10",it)  ; v at 10 m, mass point
    end if

    tf2 = 1.8*tc2+32.                    ; Turn temperature into Fahrenheit
      tf2@description = "Surface Temperature"
      tf2@units = "F"
    td_f = 1.8*td2+32.                   ; Turn temperature into Fahrenheit
      td_f@description = "Surface Dew Point Temp" 
      td_f@units = "F"
    u10 = u10*1.94386                ; Turn wind into knots
    v10 = v10*1.94386
      u10@units = "kts"
      v10@units = "kts"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Plotting options for T                
      opts = res         
      opts@cnFillOn = True  
      opts@ContourParameters = (/ -20., 90., 5./)
      opts@gsnSpreadColorEnd = -3  ; End third from the last color in color map
      contour_tc = wrf_contour(a,wks,tf2,opts)
      contour_tc2 = wrf_contour(a,wks,tf2,opts)
      delete(opts)


    ; Plotting options for Td
      opts = res         
      opts@cnFillOn = True 
      opts@cnLinesOn = True
      opts@cnLineLabelsOn = True
      opts@ContourParameters = (/ -20., 90., 5./) 
      opts@cnLineLabelBackgroundColor = -1
      opts@gsnSpreadColorEnd = -3  ; End third from the last color in color map
      contour_td = wrf_contour(a,wks,td_f,opts)
      delete(opts)


    ; Plotting options for SLP                     
      opts = res         
      opts@cnFillOn = True 
      contour_psl2 = wrf_contour(a,wks,slp,opts)
      opts@ContourParameters = (/ 996, 1032., 4. /)
      opts@cnFillOn = False 
      opts@cnInfoLabelOrthogonalPosF = -0.115
      opts@cnLineColor = "NavyBlue"
      opts@cnHighLabelsOn = True
      opts@cnLowLabelsOn = True
      opts@cnLineLabelBackgroundColor = -1
      opts@gsnContourLineThicknessesScale = 2.0
      contour_psl = wrf_contour(a,wks,slp,opts)
      delete(opts)

    ; Plotting options for Wind Vectors                 
      opts = res         
      opts@FieldTitle = "Wind"       ; overwrite Field Title
      opts@NumVectors = 35           ; density of wind barbs
      vector = wrf_vector(a,wks,u10,v10,opts)
      delete(opts)
  

    ; MAKE PLOTS                                       
      plots(0) = wrf_map_overlays(a,wks,(/contour_tc/),pltres,mpres)
      plots(1) = wrf_map_overlays(a,wks,(/contour_tc2,contour_psl/),pltres,mpres)
      plots(2) = wrf_map_overlays(a,wks,(/contour_td/),pltres,mpres)
      plots(3) = wrf_map_overlays(a,wks,(/contour_psl2,vector/),pltres,mpres3)
     

; Panel the WRF plots.
  pnlres                            = True
  pnlres@txString                   = "PLOTS for : " + times(it)
  pnlres@gsnPanelYWhiteSpacePercent = 5       ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex = 1

  gsn_panel(wks,(/plots/),(/2,2/),pnlres)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  end do        ; END OF TIME LOOP

end
