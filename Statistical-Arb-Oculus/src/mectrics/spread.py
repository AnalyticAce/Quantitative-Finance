def calculate_spread(closing_prices_asset_1, closing_prices_asset_2):

    if len(closing_prices_asset_1) != len(closing_prices_asset_2):
        raise ValueError("Input lists must have the same length")

    spread = [a - b for a, b in zip(closing_prices_asset_1, closing_prices_asset_2)]

    return spread
