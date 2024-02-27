XStruct toolbox
---------------

The functions in this toolbox originate from the OET XBeach toolbox where they were intended to hold complex structures. Basicly, these structures held entire XBeach model setups. Originally, the functions had a xb_ prefix whereas they now have a xs_ prefix.

Because the functions were reasonably generic, it was decided to remove them from the XBeach namespace and give them their own namespace. There are, however, some dependendencies left that relate these function to the XBeach toolbox. These will be removed in the near future (I hope).

Some known dependencies are:

- xs_show provides a view option that only works with XBeach structures
- xs_show provides additional options in case of XBeach input is provided
- xs_show contains an interactive toggle that is related to the XBeach preferences