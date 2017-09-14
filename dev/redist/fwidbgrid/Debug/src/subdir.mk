################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../src/CommandLineArguments.cpp \
../src/Grid.cpp \
../src/GridField.cpp \
../src/fwidbmgr.cpp 

OBJS += \
./src/CommandLineArguments.o \
./src/Grid.o \
./src/GridField.o \
./src/fwidbmgr.o 

CPP_DEPS += \
./src/CommandLineArguments.d \
./src/Grid.d \
./src/GridField.d \
./src/fwidbmgr.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -D__OPENSUSE_11_3__ -I"/home/meteo/dev/redist/fwidbmgr/include" -I/usr/include/pgsql -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


