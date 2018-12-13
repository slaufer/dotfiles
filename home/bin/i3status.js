#!/usr/bin/node
const si = require("systeminformation");
const disk = require("diskusage");
const process = require("process");
const strftime = require("strftime");
const filesize = require("filesize");

const sleep = t => new Promise(r => setTimeout(r, t));
const leftpad = (str, len, fill = "0") =>
  new Array(len - str.length).fill(fill).join("") + str;
const grad = frac =>
  `#${leftpad(Math.round((1 - frac) * 0xff).toString(16), 2)}${leftpad(
    Math.round(frac * 0xff).toString(16),
    2
  )}00`;

const weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const clockModule = async () => [
  {
    name: "clock",
    full_text: `${weekdays[strftime("%w")]} ${strftime("%Y-%m-%d %I:%M:%S %p")}`
  }
];

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
        instance: `${iface.iface}-rxlabel`,
        full_text: "\u25bc",
        separator: false
      },
      {
        name: "net",
        instance: `${iface.iface}-rx`,
        full_text: leftpad(
          filesize(Math.round(iface.rx_sec), { standard: "iec", round: 0 }),
          8,
          " "
        ),
        color: "#ff0000",
        separator: false
      },
      {
        name: "net",
        instance: `${iface.iface}-txlabel`,
        full_text: "\u25b2",
        separator: false
      },
      {
        name: "net",
        instance: `${iface.iface}-tx`,
        full_text: leftpad(
          filesize(Math.round(iface.tx_sec), { standard: "iec", round: 0 }),
          8,
          " "
        ),
        color: "#00ff00"
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

const diskModule = async (...paths) => {
  const mounts = await Promise.all(
    paths.map(
      path =>
        new Promise((res, rej) =>
          disk.check(path, (err, obj) =>
            err ? rej(err) : res({ path, ...obj })
          )
        )
    )
  );

  return mounts.reduce((acc, mount, i, arr) => {
    acc.push(
      {
        name: "disk",
        instance: `${mount.path}-label`,
        full_text: mount.path,
        separator: false
      },
      {
        name: "disk",
        instance: mount.path,
        color: grad(1 - (mount.total - mount.available) / mount.total),
        full_text: filesize(mount.available, { standard: "iec" }),
        separator: i === arr.length - 1
      }
    );

    return acc;
  }, []);
};

const cpuModule = async path => [
  { name: "cpu", instance: "label", full_text: "cpu", separator: false },
  ...(await new Promise(resolve =>
    si.currentLoad(load => resolve(load))
  )).cpus.map(({ load_idle }, i, arr) => ({
    name: "cpu",
    instance: `cpu${i}`,
    color: grad(load_idle / 100),
    full_text: leftpad(Math.round(100 - load_idle).toString(10) + "%", 4, " "),
    separator: i === arr.length - 1
  }))
];

const memoryModule = async () => {
  const { free, total, swapfree, swaptotal } = await new Promise(resolve =>
    si.mem(obj => resolve(obj))
  );
  return [
    {
      name: "memory",
      instance: "memlabel",
      full_text: "mem",
      separator: false
    },
    {
      name: "memory",
      instance: "memory",
      color: grad(free / total),
      full_text: leftpad(
        filesize(free, { standard: "iec", round: 2 }),
        11,
        " "
      ),
      separator: false
    },
    {
      name: "memory",
      instance: "swaplabel",
      full_text: "swap",
      separator: false
    },
    {
      name: "memory",
      instance: "swap",
      color: grad(swapfree / swaptotal),
      full_text: leftpad(
        filesize(swapfree, { standard: "iec", round: 2 }),
        11,
        " "
      )
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
            diskModule("/", "/media/sf_Downloads"),
            netModule("enp0s3"),
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
