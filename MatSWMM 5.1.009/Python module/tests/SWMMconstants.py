# -*- coding : utf-8 -*-

#-------------------------------------
# Names of major object types
#-------------------------------------
# ObjectType
GAGE = 0                            # rain gage
SUBCATCH = 1                        # subcatchment
NODE = 2                            # conveyance system node
LINK = 3                            # conveyance system link
POLLUT = 4                          # pollutant
LANDUSE = 5                         # land use category
TIMEPATTERN = 6                     # dry weather flow time pattern
CURVE = 7                           # generic table of values
TSERIES = 8                         # generic time series of values
CONTROL = 9                         # conveyance system control rules
TRANSECT = 10                       # irregular channel cross-section
AQUIFER = 11                        # groundwater aquifer
UNITHYD = 12                        # RDII unit hydrograph
SNOWMELT = 13                       # snowmelt parameter set
SHAPE = 14                          # custom conduit shape
LID = 15                            # LID treatment units
MAX_OBJ_TYPES = 1

#-------------------------------------
# Names of Node sub-types
#-------------------------------------
# NodeType
JUNCTION = 0
OUTFALL = 1
STORAGE = 2
DIVIDER = 3
MAX_NODE_TYPES = 4

#-------------------------------------
# Names of Link sub-types
#-------------------------------------
# LinkType
CONDUIT = 0
PUMP = 1
ORIFICE = 2
WEIR = 3
OUTLET = 4
MAX_LINK_TYPES = 5

#-------------------------------------
# File types
#-------------------------------------
# FileType
RAINFALL_FILE = 0                   # rainfall file
RUNOFF_FILE = 1                     # runoff file
HOTSTART_FILE = 2                   # hotstart file
RDII_FILE = 3                       # RDII file
INFLOWS_FILE = 4                    # inflows interface file
OUTFLOWS_FILE = 5                   # outflows interface file

#-------------------------------------
# File usage types
#-------------------------------------
# FileUsageType
NO_FILE = 0                         # no file usage
SCRATCH_FILE = 1                    # use temporary scratch file
USE_FILE = 2                        # use previously saved file
SAVE_FILE = 3                       # save file currently in use

#-------------------------------------
# Rain gage data types
#-------------------------------------
# GageDataType
RAIN_TSERIES = 0                    # rainfall from user-supplied time series
RAIN_FILE = 1                       # rainfall from external file

#-------------------------------------
# Cross section shape types
#-------------------------------------
 # XsectType
DUMMY = 0                           # 0
CIRCULAR = 1                        # 1      closed
FILLED_CIRCULAR = 2                 # 2      closed
RECT_CLOSED = 3                     # 3      closed
RECT_OPEN = 4                       # 4
TRAPEZOIDAL = 5                     # 5
TRIANGULAR = 6                      # 6
PARABOLIC = 7                       # 7
POWERFUNC = 8                       # 8
RECT_TRIANG = 9                     # 9
RECT_ROUND = 10                     # 10
MOD_BASKET = 11                     # 11
HORIZ_ELLIPSE = 12                  # 12     closed
VERT_ELLIPSE = 13                   # 13     closed
ARCH = 14                           # 14     closed
EGGSHAPED = 15                      # 15     closed
HORSESHOE = 16                      # 16     closed
GOTHIC = 17                         # 17     closed
CATENARY = 18                       # 18     closed
SEMIELLIPTICAL = 19                 # 19     closed
BASKETHANDLE = 20                   # 20     closed
SEMICIRCULAR = 21                   # 21     closed
IRREGULAR = 22                      # 22
CUSTOM = 23                         # 22     closed
FORCE_MAIN = 24                     # 23     closed

#-------------------------------------
# Measurement units types
#-------------------------------------
# UnitsType
US = 0                              # US units
SI = 1                              # SI (metric) units

# FlowUnitsType
CFS = 0                             # cubic feet per second
GPM = 1                             # gallons per minute
MGD = 2                             # million gallons per day
CMS = 3                             # cubic meters per second
LPS = 4                             # liters per second
MLD = 5                             # million liters per day

# ConcUnitsType
MG = 0                              # Milligrams / L
UG = 1                              # Micrograms / L
COUNT = 2                           # Counts / L

#--------------------------------------
# Quantities requiring unit conversions
#--------------------------------------
# ConversionType
RAINFALL = 0
RAINDEPTH = 1
EVAPRATE = 2
LENGTH = 3
LANDAREA = 4
VOLUME = 5
WINDSPEED = 6
TEMPERATURE = 7
MASS = 8
GWFLOW = 9
FLOW = 10                           # Flow must always be listed last

#-------------------------------------
# Computed subcatchment quantities
#-------------------------------------
# SubcatchResultType
SUBCATCH_RAINFALL = 0               # rainfall intensity
SUBCATCH_SNOWDEPTH = 1              # snow depth
SUBCATCH_EVAP = 2                   # evap loss
SUBCATCH_INFIL = 3                  # infil loss
SUBCATCH_RUNOFF = 4                 # runoff flow rate
SUBCATCH_GW_FLOW = 5                # groundwater flow rate to node
SUBCATCH_GW_ELEV = 6                # elevation of saturated gw table
SUBCATCH_SOIL_MOIST = 7             # soil moisture
SUBCATCH_WASHOFF = 8                # pollutant washoff concentration
MAX_SUBCATCH_RESULTS = 9

#-------------------------------------
# Computed node quantities
#-------------------------------------
# NodeResultType
NODE_DEPTH = 0                      # water depth above invert
NODE_HEAD = 1                       # hydraulic head
NODE_VOLUME = 2                     # volume stored & ponded
NODE_LATFLOW = 3                    # lateral inflow rate
NODE_INFLOW = 4                     # total inflow rate
NODE_OVERFLOW = 5                   # overflow rate
NODE_QUAL = 6                       # concentration of each pollutant
MAX_NODE_RESULTS = 7

#-------------------------------------
# Computed link quantities
#-------------------------------------
# LinkResultType
LINK_FLOW = 0                       # flow rate
LINK_DEPTH = 1                      # flow depth
LINK_VELOCITY = 2                   # flow velocity
LINK_VOLUME = 3                     # link volume
LINK_CAPACITY = 4                   # ratio of area to full area
LINK_QUAL = 5                       # concentration of each pollutant
MAX_LINK_RESULTS = 6

#-------------------------------------
# System-wide flow quantities
#-------------------------------------
# SysFlowType
SYS_TEMPERATURE = 0                  # air temperature
SYS_RAINFALL = 1                     # rainfall intensity
SYS_SNOWDEPTH = 2                    # snow depth
SYS_INFIL = 3                        # infil
SYS_RUNOFF = 4                       # runoff flow
SYS_DWFLOW = 5                       # dry weather inflow
SYS_GWFLOW = 6                       # ground water inflow
SYS_IIFLOW = 7                       # RDII inflow
SYS_EXFLOW = 8                       # external inflow
SYS_INFLOW = 9                       # total lateral inflow
SYS_FLOODING = 10                    # flooding outflow
SYS_OUTFLOW = 11                     # outfall outflow
SYS_STORAGE = 12                     # storage volume
SYS_EVAP = 13                        # evaporation
MAX_SYS_RESULTS = 14

#-------------------------------------
# Conduit flow classifications
#-------------------------------------
# FlowClassType
DRY = 0                             # dry conduit
UP_DRY = 1                          # upstream end is dry
DN_DRY = 2                          # downstream end is dry
SUBCRITICAL = 3                     # sub-critical flow
SUPCRITICAL = 4                     # super-critical flow
UP_CRITICAL = 5                     # free-fall at upstream end
DN_CRITICAL = 6                     # free-fall at downstream end
MAX_FLOW_CLASSES = 7                # number of distinct flow classes      #(5.1.008)
UP_FULL = 8                         # upstream end is full                 #(5.1.008)
DN_FULL = 9                         # downstream end is full               #(5.1.008)
ALL_FULL = 10                       # completely full                      #(5.1.008)
# MAX_FLOW_CLASSES = 7                                                  #(5.1. = 08)


#  Added to release 5.1.008.  #                                          #(5.1.008)
#------------------------
# Runoff flow categories
#------------------------
# RunoffFlowType
RUNOFF_RAINFALL = 0                  # rainfall
RUNOFF_EVAP = 1                      # evaporation
RUNOFF_INFIL = 2                     # infiltration
RUNOFF_RUNOFF = 3                    # runoff
RUNOFF_DRAINS = 4                    # LID drain flow
RUNOFF_RUNON = 5                     # runon from outfalls

#-------------------------------------
# Surface pollutant loading categories
#-------------------------------------
# LoadingType
BUILDUP_LOAD = 0                    # pollutant buildup load
DEPOSITION_LOAD = 1                 # rainfall deposition load
SWEEPING_LOAD = 2                   # load removed by sweeping
BMP_REMOVAL_LOAD = 3                # load removed by BMPs
INFIL_LOAD = 4                      # runon load removed by infiltration
RUNOFF_LOAD = 5                     # load removed by runoff
FINAL_LOAD = 6                      # load remaining on surface

#-------------------------------------
# Input data options
#-------------------------------------
# RainfallType
RAINFALL_INTENSITY = 0              # rainfall expressed as intensity
RAINFALL_VOLUME = 1                 # rainfall expressed as volume
CUMULATIVE_RAINFALL = 2             # rainfall expressed as cumulative volume

# TempType
NO_TEMP = 0                         # no temperature data supplied
TSERIES_TEMP = 1                    # temperatures come from time series
FILE_TEMP = 2                       # temperatures come from file

#  WindType
MONTHLY_WIND = 0                    # wind speed varies by month
FILE_WIND = 1                       # wind speed comes from file

# EvapType
CONSTANT_EVAP = 0                   # constant evaporation rate
MONTHLY_EVAP = 1                    # evaporation rate varies by month
TIMESERIES_EVAP = 2                 # evaporation supplied by time series
TEMPERATURE_EVAP = 3                # evaporation from daily temperature
FILE_EVAP = 4                       # evaporation comes from file
RECOVERY = 5                        # soil recovery pattern
DRYONLY = 7                         # evap. allowed only in dry periods

# NormalizerType
PER_AREA = 0                        # buildup is per unit or area
PER_CURB = 1                        # buildup is per unit of curb length

# BuildupType
NO_BUILDUP = 0                      # no buildup
POWER_BUILDUP = 1                   # power function buildup equation
EXPON_BUILDUP = 2                   # exponential function buildup equation
SATUR_BUILDUP = 3                   # saturation function buildup equation
EXTERNAL_BUILDUP = 4                # external time series buildup

# WashoffType
NO_WASHOFF = 0                      # no washoff
EXPON_WASHOFF = 1                   # exponential washoff equation
RATING_WASHOFF = 2                  # rating curve washoff equation
EMC_WASHOFF = 3                     # event mean concentration washoff

#  SubAreaType
IMPERV0 = 0                         # impervious w/o depression storage
IMPERV0 = 1                         # impervious w/ depression storage
PERV = 2                            # pervious

# RunoffRoutingType
TO_OUTLET = 0                       # perv & imperv runoff goes to outlet
TO_IMPERV = 1                       # perv runoff goes to imperv area
TO_PERV = 2                         # imperv runoff goes to perv subarea

# RouteModelType
NO_ROUTING = 0                      # no routing
SF = 1                              # steady flow model
KW = 2                              # kinematic wave model
EKW = 3                             # extended kin. wave model
DW = 4                              # dynamic wave model

# ForceMainType
H_W = 0                             # Hazen-Williams eqn.
D_W = 1                             # Darcy-Weisbach eqn.

# OffsetType
DEPTH_OFFSET = 0                    # offset measured as depth
ELEV_OFFSET = 1                     # offset measured as elevation

# KinWaveMethodType
NORMAL = 0                          # normal method
MODIFIED = 1                        # modified method

#  CompatibilityType
SWMM4 = 0                           # SWMM 4 weighting for area & hyd. radius
SWMM2 = 1                           # SWMM 2 weighting
SWMM3 = 2                           # SWMM 3 weighting

# NormalFlowType
SLOPE = 0                           # based on slope only
FROUDE = 1                          # based on Fr only
BOTH = 2                            # based on slope & Fr

# InertialDampingType
NO_DAMPING = 0                      # no inertial damping
PARTIAL_DAMPING = 1                 # partial damping
FULL_DAMPING = 2                    # full damping

# InflowType
EXTERNAL_INFLOW = 0                 # user-supplied external inflow
DRY_WEATHER_INFLOW = 1              # user-supplied dry weather inflow
WET_WEATHER_INFLOW = 2              # computed runoff inflow
GROUNDWATER_INFLOW = 3              # computed groundwater inflow
RDII_INFLOW = 4                     # computed I&I inflow
FLOW_INFLOW = 5                     # inflow parameter is flow
CONCEN_INFLOW = 6                   # inflow parameter is pollutant concen.
MASS_INFLOW = 7                     # inflow parameter is pollutant mass

# PatternType
MONTHLY_PATTERN = 0                 # DWF multipliers for each month
DAILY_PATTERN = 1                   # DWF multipliers for each day of week
HOURLY_PATTERN = 2                  # DWF multipliers for each hour of day
WEEKEND_PATTERN = 3                 # hourly multipliers for week end days

# OutfallType
FREE_OUTFALL = 0                    # critical depth outfall condition
NORMAL_OUTFALL = 1                  # normal flow depth outfall condition
FIXED_OUTFALL = 2                   # fixed depth outfall condition
TIDAL_OUTFALL = 3                   # variable tidal stage outfall condition
TIMESERIES_OUTFALL = 4              # variable time series outfall depth

# StorageType
TABULAR = 0                         # area v. depth from table
FUNCTIONAL = 1                      # area v. depth from power function

# ReactorType
CSTR = 0                            # completely mixed reactor
PLUG = 1                            # plug flow reactor

# TreatmentType
REMOVAL = 0                         # treatment stated as a removal
CONCEN = 1                          # treatment stated as effluent concen.

# DividerType
CUTOFF_DIVIDER = 0                  # diverted flow is excess of cutoff flow
TABULAR_DIVIDER = 1                 # table of diverted flow v. inflow
WEIR_DIVIDER = 2                    # diverted flow proportional to excess flow
OVERFLOW_DIVIDER = 3                # diverted flow is flow > full conduit flow

# PumpCurveType
TYPE1_PUMP = 0                      # flow varies stepwise with wet well volume
TYPE2_PUMP = 1                      # flow varies stepwise with inlet depth
TYPE3_PUMP = 2                      # flow varies with head delivered
TYPE4_PUMP = 3                      # flow varies with inlet depth
IDEAL_PUMP = 4                      # outflow equals inflow

# OrificeType
SIDE_ORIFICE = 0                    # side orifice
BOTTOM_ORIFICE = 1                  # bottom orifice

# WeirType
TRANSVERSE_WEIR = 0                 # transverse weir
SIDEFLOW_WEIR = 1                   # side flow weir
VNOTCH_WEIR = 2                     # V-notch (triangular) weir
TRAPEZOIDAL_WEIR = 3                # trapezoidal weir

# CurveType
STORAGE_CURVE = 0                   # surf. area v. depth for storage node
DIVERSION_CURVE = 1                 # diverted flow v. inflow for divider node
TIDAL_CURVE = 2                     # water elev. v. hour of day for outfall
RATING_CURVE = 3                    # flow rate v. head for outlet link
CONTROL_CURVE = 4                   # control setting v. controller variable
SHAPE_CURVE = 5                     # width v. depth for custom x-section
PUMP1_CURVE = 6                     # flow v. wet well volume for pump
PUMP2_CURVE = 7                     # flow v. depth for pump (discrete)
PUMP3_CURVE = 8                     # flow v. head for pump (continuous)
PUMP4_CURVE = 9                     # flow v. depth for pump (continuous)

 # InputSectionType
s_TITLE = 0
s_OPTION = 1
s_FILE = 2
s_RAINGAGE = 3
s_TEMP = 4
s_EVAP = 5
s_SUBCATCH = 6
s_SUBAREA = 7
s_INFIL = 8
s_AQUIFER = 9
s_GROUNDWATER = 10
s_SNOWMELT = 11
s_JUNCTION = 12
s_OUTFALL = 13
s_STORAGE = 14
s_DIVIDER = 15
s_CONDUIT = 16
s_PUMP = 17
s_ORIFICE = 18
s_WEIR = 19
s_OUTLET = 20
s_XSECTION = 21
s_TRANSECT = 22
s_LOSSES = 23
s_CONTROL = 24
s_POLLUTANT = 25
s_LANDUSE = 26
s_BUILDUP = 27
s_WASHOFF = 28
s_COVERAGE = 29
s_INFLOW = 30
s_DWF = 31
s_PATTERN = 32
s_RDII = 33
s_UNITHYD = 34
s_LOADING = 35
s_TREATMENT = 36
s_CURVE = 37
s_TIMESERIES = 38
s_REPORT = 39
s_COORDINATE = 40
s_VERTICES = 41
s_POLYGON = 42
s_LABEL = 43
s_SYMBOL = 44
s_BACKDROP = 45
s_TAG = 46
s_PROFILE = 47
s_MAP = 48
s_LID_CONTROL = 49
s_LID_USAGE = 50
s_GWF = 51                   #(5.1.007)
s_ADJUS = 52                 #(5.1.007)

# InputOptionType
FLOW_UNITS = 0
INFIL_MODEL = 1
ROUTE_MODEL = 2
START_DATE = 3
START_TIME = 4
END_DATE = 5
END_TIME = 6
REPORT_START_DATE = 7
REPORT_START_TIME = 8
SWEEP_START = 9
SWEEP_END = 10
START_DRY_DAYS = 11
WET_STEP = 12
DRY_STEP = 13
ROUTE_STEP = 14
REPORT_STEP = 15
ALLOW_PONDING = 16
INERT_DAMPING = 17
SLOPE_WEIGHTING = 18
VARIABLE_STEP = 19
NORMAL_FLOW_LTD = 20
LENGTHENING_STEP = 21
MIN_SURFAREA = 22
COMPATIBILITY = 23
SKIP_STEADY_STATE = 24
TEMPDIR = 25
IGNORE_RAINFALL = 26
FORCE_MAIN_EQN = 27
LINK_OFFSETS = 28
MIN_SLOPE = 29
IGNORE_SNOWMELT = 30
IGNORE_GWATER = 31
IGNORE_ROUTING = 32
IGNORE_QUALITY = 33
MAX_TRIALS = 34
HEAD_TOL = 35
SYS_FLOW_TOL = 36
LAT_FLOW_TOL = 37
IGNORE_RDII = 38          #(5.1.004)
MIN_ROUTE_STEP = 39
NUM_THREADS = 40          #(5.1.008)

#  NoYesType
NO = 0
YES = 1

#  NoneAllType
NONE = 0
ALL = 1
SOME = 2