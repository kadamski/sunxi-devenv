#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/of.h>
#include <linux/spi/spi.h>
#include <linux/regmap.h>

const struct regmap_config test_spi_regmap_config = {
	.reg_bits = 16,
	.pad_bits = 8,
	.val_bits = 32,

	.cache_type = REGCACHE_NONE,
	.read_flag_mask = 0x800000,
};

static const struct of_device_id spi_test_match[] = {
	{
		.compatible = "k,test-regmap-spi",
	},
	{}
};
MODULE_DEVICE_TABLE(of, spi_test_match);

static int test_spi_probe(struct spi_device *spi)
{
	struct regmap *regmap;
	unsigned int val;

	dev_info(&spi->dev, "probe %p!\n", spi);

	regmap = devm_regmap_init_spi(spi, &test_spi_regmap_config);
	if (IS_ERR(regmap)) {
		dev_err(&spi->dev, "regmap_init failed with %ld\n", PTR_ERR(regmap));
		return PTR_ERR(regmap);
	}

	regmap_write(regmap, 0x1234, 0x5678);
	regmap_read(regmap, 0x1234, &val);
	regmap_read(regmap, 0xdead, &val);
	dev_info(&spi->dev, "val = %d\n", val);

	return 0;
}

static int test_spi_remove(struct spi_device *spi)
{
	pr_info("remove %p!\n", spi);

	return 0;
}

static struct spi_driver test_spi_driver = {
	.driver = {
		.name = "test_spi",
		.of_match_table = spi_test_match,
	},
	.probe = test_spi_probe,
	.remove = test_spi_remove,
};
module_spi_driver(test_spi_driver);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Krzysztof Adamski <k@japko.eu>");
