static int max96712_g_mbus_config(struct v4l2_subdev *sd, unsigned int pad,
				  struct v4l2_mbus_config *config)
{
	struct max96712 *max96712 = v4l2_get_subdevdata(sd);
	u32 val = 0;
	u8 data_lanes = max96712->bus_cfg.bus.mipi_csi2.num_data_lanes;
	int i;

	val |= V4L2_MBUS_CSI2_CONTINUOUS_CLOCK;

	config->type = V4L2_MBUS_CSI2_DPHY;
	config->bus.mipi_csi2.flags = val;
	config->bus.mipi_csi2.num_data_lanes = data_lanes;
	config->bus.mipi_csi2.clock_lane = 0; /* Usually lane 0 for clock */

	/* Set up data lane mapping */
	for (i = 0; i < data_lanes && i < V4L2_MBUS_CSI2_MAX_DATA_LANES; i++) {
		config->bus.mipi_csi2.data_lanes[i] = i + 1; /* Lanes are 1-indexed */
		config->bus.mipi_csi2.lane_polarities[i + 1] = false; /* Normal polarity */
	}
	config->bus.mipi_csi2.lane_polarities[0] = false; /* Clock lane polarity */

	return 0;
}
