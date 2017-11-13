obj-m += test-regmap-spi.o
KDIR := ../../linux/
PWD   := $(shell pwd)

all:
	make -C $(KDIR) M=$(PWD) modules

install: all
	make -C $(KDIR) M=$(PWD) modules_install

clean:
	make -C $(KDIR) M=$(PWD) clean
