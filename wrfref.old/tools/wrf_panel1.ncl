
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
  wks = gsn_open_wks(type,"plt_panel1")
  gsn_define_colormap(wks,"rainbow")  ; overwrite the .hluresfile color map


; Set some basic resources
  res = True
  res@NoHeaderFooter           = True            ; Switch headers and footers off

  pltres = True
  pltres@PanelPlot = True      ; Indicate these plots are to be paneled.
  mpres = True


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  times = wrf_user_getvar(a,"times",-1)  ; get all times in the file
  plots = new ( 4, graphic )


  do ii = 10,10
    istart = 0 + ii*3
    iend = istart+3
    iplot = 0
    do itime = istart,iend
  
      t = wrf_user_getvar(a,"T2",itime)   ; T2 in Kelvin
      slp = wrf_user_getvar(a,"slp",itime)   ; slp
  
      ; Generate contours.
        t_res = res
        t_res@cnFillOn = True          
        t_res@ContourParameters = (/ 240., 300., 5. /)
        t_res@lbLabelBarOn = False       ; Turn off individual label bars so we can
        contour = wrf_contour(a,wks,t,t_res)

        slp_res = res
        slp_res@ContourParameters = (/ 990., 1026., 2. /)
        slp_res@cnInfoLabelFontHeightF = 0.027
        con_slp = wrf_contour(a,wks,slp,slp_res)
  
      ; Overlay contours on a map
        ;pltres@NoTitles = True
        pltres@CommonTitle = True
        pltres@PlotTitle =  times(itime)
        plots(iplot) = wrf_map_overlays(a,wks,(/contour,con_slp/),pltres,mpres)
        delete(contour)
      iplot = iplot + 1
  
    end do
  
  ; Panel the WRF plots.
    pnlres                            = True
    pnlres@txString                   = t@description + "  (" + t@units + ")"
    pnlres@gsnPanelYWhiteSpacePercent = 13       ; Add white space b/w plots.
    pnlres@gsnPanelLabelBar           = True    ; Turn on common labelbar
    pnlres@lbLabelAutoStride          = True    ; Spacing of lbar labels.
    pnlres@lbBoxMinorExtentF          = 0.13

    gsn_panel(wks,(/plots/),(/2,2/),pnlres)

  end do

end
