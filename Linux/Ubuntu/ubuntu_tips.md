# 1) Packages
## a. How to check the list of packages
- Apt-get
    ```bash
    apt list --installed  # list of packages installed through apt-get
    ```
- Snap
    ```bash
    snap list  # list of snap packages
    ```

# 2) Networks
## a. Speedtest from 
```bash
speedtest
```
![speedtest_results.png](./images/speedtest_results.png)
- Latency: measures how quickly the device gets a response after one somebody has sent out a request.
- ISP (Internet Service Provider): company providing internet access.
- Idle
    - ``Latency``: test measuring the response on the network when it is not in use.
    - ``Download``: latency is measured while the download test is in progress to see how it is affected by the download activity on the network.
    - ``Upload``: latency is measured while the upload test is in progress to see how it is affected by the upload activity on the network.