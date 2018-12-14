#!/usr/bin/node
const _ = require("lodash");
const si = require("systeminformation");
const diskusage = require("diskusage");
const process = require("process");
const strftime = require("strftime");
const filesize = require("filesize");

const sleep = t => new Promise(r => setTimeout(r, t));
const parseColor = color => ({
  r: parseInt(color.slice(1, 3), 16),
  g: parseInt(color.slice(3, 5), 16),
  b: parseInt(color.slice(5, 7), 16)
});

const grad = (frac, startColor = "#ff0000", endColor = "#00ff00") => {
  const start = parseColor(startColor);
  const end = parseColor(endColor);
  const r = _.padStart(
    (start.r + Math.round(frac * (end.r - start.r))).toString(16),
    2,
    "0"
  );
  const g = _.padStart(
    (start.g + Math.round(frac * (end.g - start.g))).toString(16),
    2,
    "0"
  );
  const b = _.padStart(
    (start.b + Math.round(frac * (end.b - start.b))).toString(16),
    2,
    "0"
  );

  return `#${r}${g}${b}`;
};

const weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const clockModule = async () => [
  {
    name: "clock",
    full_text: `${weekdays[strftime("%w")]} ${strftime("%Y-%m-%d %I:%M:%S %p")}`
  }
];

const netPeak = {};
const netModule = async (...selected) => {
  const ifaces = (await si.networkInterfaces()).filter(
    iface => !selected.length || selected.includes(iface.iface)
  );

  const stats = await Promise.all(
    ifaces.map(iface =>
      si.networkStats(iface.iface).then(stats => ({ ...iface, ...stats }))
    )
  );
  return stats.reduce((acc, iface) => {
    const peak = (netPeak[iface.iface] = netPeak[iface.iface] || {});
    peak.rx = Math.max(peak.rx || 0, iface.rx_sec);
    peak.tx = Math.max(peak.tx || 0, iface.tx_sec);

    acc.push(
      {
        name: "net",
        instance: `${iface.iface}-label`,
        full_text: iface.iface,
        separator: false
      },
      {
        name: "net",
        instance: `${iface.iface}-ip`,
        full_text: iface.ip4,
        color: iface.operstate === "up" ? "#00ff00" : "#ff0000",
        separator: false
      },
      {
        name: "net",
        instance: `${iface.iface}-rx`,
        full_text: `\u25bc${_.pad(
          filesize(Math.round(iface.rx_sec), { standard: "iec", round: 1 }),
          10
        )}`,
        color: "#000000",
        background: grad(1 - iface.rx_sec / peak.rx),
        separator: false,
        separator_block_width: 0
      },
      {
        name: "net",
        instance: `${iface.iface}-tx`,
        full_text: `\u25b2${_.pad(
          filesize(Math.round(iface.tx_sec), { standard: "iec", round: 1 }),
          10
        )}`,
        color: "#000000",
        background: grad(1 - iface.tx_sec / peak.tx)
      }
    );
    return acc;
  }, []);

  return ifaces.map(iface => ({
    name: "net",
    instance: iface.name,
    full_text: `${iface.name}: ${iface.ip_address}`
  }));
};

const diskModule = async (...disks) => {
  const mounts = await Promise.all(
    disks.map(disk =>
      diskusage.check(disk.path).then(info => ({ ...info, ...disk }))
    )
  );

  return mounts.reduce((acc, mount, i, arr) => {
    acc.push({
      name: "disk",
      instance: mount.label,
      color: "#000000",
      background: grad(1 - (mount.total - mount.available) / mount.total),
      full_text: ` ${mount.label} `,
      separator: i === arr.length - 1,
      separator_block_width: i === arr.length - 1 ? undefined : 0
    });

    return acc;
  }, []);
};

const cpuModule = async path =>
  si.currentLoad().then(load => load.cpus.map(({ load_idle }, i, arr) => ({
    name: "cpu",
    instance: `cpu${i}`,
    color: "#000000",
    background: grad(load_idle / 100),
    full_text: ` ${i} `,
    separator: i === arr.length - 1,
    separator_block_width: i === arr.length - 1 ? undefined : 0
  })));

const memoryModule = async () => {
  const { available, total, swapfree, swaptotal } = await new Promise(resolve =>
    si.mem(obj => resolve(obj))
  );
  return [
    {
      name: "memory",
      instance: "memory",
      color: "#000000",
      background: grad(available / total),
      full_text: " m ",
      separator: false,
      separator_block_width: 0
    },
    {
      name: "memory",
      instance: "swap",
      color: "#000000",
      background: grad(swapfree / swaptotal),
      full_text: " s "
    }
  ];
};

const main = async () => {
  console.log(JSON.stringify({ version: 1 }));
  console.log("[\n[]");

  while (true) {
    console.log(
      "," +
        JSON.stringify(
          (await Promise.all([
            netModule("enp0s3"),
            diskModule(
              { path: "/", label: "/" },
              { path: "/media/sf_Downloads", label: "dl" }
            ),
            memoryModule(),
            cpuModule(),
            clockModule()
          ])).reduce((acc, sections) => [...acc, ...sections], [])
        )
    );
    await sleep(1000);
  }
};

main().then(
  () => process.exit(0),
  e => {
    console.error(e);
    process.exit(1);
  }
);
