#!/usr/bin/node
const _ = require("lodash");
const si = require("systeminformation");
const diskusage = require("diskusage");
const process = require("process");
const strftime = require("strftime");
const filesize = require("filesize");
const { execSync } = require("child_process");

const parseColor = color => ({
  r: parseInt(color.slice(1, 3), 16),
  g: parseInt(color.slice(3, 5), 16),
  b: parseInt(color.slice(5, 7), 16)
});

const getColor = (frac, start, end) =>
  _.padStart((start + Math.round(frac * (end - start))).toString(16), 2, "0");

const grad = (frac, startColor = "#ff4444", endColor = "#44ff44") => {
  const start = parseColor(startColor);
  const end = parseColor(endColor);
  const r = getColor(frac, start.r, end.r);
  const g = getColor(frac, start.g, end.g);
  const b = getColor(frac, start.b, end.b);
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
let ifaces = [];
const netModule = async (...selected) => {
  if (!ifaces) {
    ifaces = (await si.networkInterfaces()).filter(
      iface => !selected.length || selected.includes(iface.iface)
    );
  }

  const stats = await Promise.all(
    ifaces.map(iface =>
      si.networkStats(iface.iface).then(stats => ({ ...iface, ...stats }))
    )
  );
  return stats.reduce((acc, iface) => {
    const peak = (netPeak[iface.iface] = netPeak[iface.iface] || {});
    peak.rx = Math.max(peak.rx || 0, iface.rx_sec);
    peak.tx = Math.max(peak.tx || 0, iface.tx_sec);

    console.log(iface);

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
        full_text: iface.ip4 || iface.ip6,
        color: iface.operstate === "up" ? "#00ff00" : "#ff0000",
        separator: false
      },
      {
        name: "net",
        instance: `${iface.iface}-rx`,
        full_text: `\u25bc${_.pad(
          filesize(iface.rx_sec === -1 ? 0 : Math.round(iface.rx_sec), { standard: "iec", round: 1 }),
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
          filesize(iface.tx_sec === -1 ? 0 : Math.round(iface.tx_sec), { standard: "iec", round: 1 }),
          10
        )}`,
        color: "#000000",
        background: grad(1 - iface.tx_sec / peak.tx),
        separator: false
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
      separator: false,
      separator_block_width: i === arr.length - 1 ? undefined : 0
    });

    return acc;
  }, []);
};

const cpuModule = async path =>
  si.currentLoad().then(load =>
    load.cpus.map(({ load_idle }, i, arr) => ({
      name: "cpu",
      instance: `cpu${i}`,
      color: "#000000",
      background: grad(load_idle / 100),
      full_text: ` ${i} `,
      separator: false,
      separator_block_width: i === arr.length - 1 ? undefined : 0
    }))
  );

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
      full_text: " s ",
      separator: false
    }
  ];
};

const main = async (modules, options) => {
  console.log(JSON.stringify({ version: 1 }));
  console.log("[\n[]");

  modules.forEach(module => (module.last = 0));

  const { interval = 1000 } = options;
  const data = [];

  while (true) {
    const now = Date.now();

    modules.forEach((module, i) => {
      if (module.last + module.interval > now) {
        return;
      }

      const args = module.args || [];
      module.fn(...args).then(output => (data[i] = output));
      module.last = now;
    });

    console.log("," + JSON.stringify(_.flatten(data)));

    await new Promise(r => setTimeout(r, interval));
  }
};

const modules = [
  { fn: netModule, args: ["enp0s3"], interval: 1000 },
  {
    fn: diskModule,
    args: [
      { path: "/", label: "/" },
      { path: "/media/sf_Downloads", label: "dl" }
    ],
    interval: 15000
  },
  { fn: memoryModule, interval: 500 },
  { fn: cpuModule, interval: 500 },
  { fn: clockModule, interval: 1000 }
];

main(modules, { interval: 250 }).then(
  () => process.exit(0),
  e => {
    console.error(e);
    process.exit(1);
  }
);
