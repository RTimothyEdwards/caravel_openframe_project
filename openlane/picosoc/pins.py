cycle = [
    "gpio_loopback_zero",
    "gpio_loopback_one",
    "gpio_in_h",
    "gpio_oeb",
    "gpio_ib_mode_sel",
    "gpio_vtrip_sel",
    "gpio_out",
    "gpio_holdover",
    "gpio_dm2",
    "gpio_anlaog_sel",
    "gpio_ieb",
    "gpio_analog_pol",
    "gpio_dm0",
    "gpio_analog_en",
    "gpio_noesd_io",
    "gpio_dm1",
    "analog_io",
    "gpio_slow_sel",
    "gpio_in",
]

pico_pins = """
    porb
    por
    resetb
    mask_rev
    gpio_in
    gpio_out
    gpio_oeb
    gpio_ieb - missing ??
    gpio_ib_mode_sel
    gpio_vtrip_sel
    gpio_slow_sel
    gpio_dm2
    gpio_dm1
    gpio_dm0
    gpio_loopback_one
    gpio_loopback_zero
"""

ranges = {
        "N": (23, 15),
        "E": (0, 14),
        "S": (38, 43),
        "W": (37, 24)
        }

def my_range(lower, upper):
    if lower > upper:
        value = list(range(upper, lower+1))
        value.reverse()
        return value
    else:
        return list(range(lower, upper + 1))
for side in ranges:
    limits = ranges[side]
    new_cycle = cycle.copy()
    if side in ["E", "S"]:
        new_cycle.reverse()
    print(f"#{side}")
    for i in my_range(limits[0], limits[1]):
        for pin in new_cycle:
            print(f"{pin}\\[{i}\\]")
