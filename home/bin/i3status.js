#!/usr/bin/node
const si = require("systeminformation");
const disk = require("diskusage");
const network = require("network");
const process = require("process");
const strftime = require("strftime");
const filesize = require("filesize");

const sleep = t => new Promise(r => setTimeout(r, t));
const leftpad = (str, len, fill = "0") => new Array(len - str.length).fill(fill).join("") + str;
const grad = frac =>
  `#${leftpad(Math.round((1 - frac) * 0xff).toString(16), 2)}${leftpad(Math.round(frac * 0xff).toString(16), 2)}00`;

const weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const clockModule = async () => [{ full_text: ` ${weekdays[strftime("%w")]} ${strftime("%Y-%m-%d %I:%M:%S %p")} ` }];

const netModule = async () => {
  const ifaces = await new Promise((resolve, reject) =>
    network.get_interfaces_list((err, obj) => (err ? reject(err) : resolve(obj)))
  );

  return ifaces.map(iface => ({ full_text: ` ${iface.name}: ${iface.ip_address} ` }));
};

const diskModule = async (...paths) =>
  Promise.all(
    paths.map(async path => {
      const { available, total } = await new Promise((resolve, reject) =>
        disk.check(path, (err, obj) => (err ? reject(err) : resolve(obj)))
      );

      return {
        color: grad(1 - (total - available) / total),
        full_text: ` ${path}: ${filesize(available, { standard: "iec" })} `
      };
    })
  );

const cpuModule = async path =>
  (await new Promise(resolve => si.currentLoad(load => resolve(load)))).cpus.map(({ load_idle }, i) => ({
    color: grad(load_idle / 100),
    full_text: ` CPU${i}: ${Math.round(100 - load_idle).toString(10)}% `
  }));

const memoryModule = async () => {
  const { free, total, swapfree, swaptotal } = await new Promise(resolve => si.mem(obj => resolve(obj)));
  return [
    { color: grad(free / total), full_text: ` MEM: ${filesize(free, { standard: "iec" })} ` },
    { color: grad(swapfree / swaptotal), full_text: ` SWAP: ${filesize(swapfree, { standard: "iec" })} ` }
  ];
}

const main = async () => {
  console.log(JSON.stringify({ version: 1 }));
  console.log("[\n[]");

  while (true) {
    console.log(
      "," +
        JSON.stringify(
          (await Promise.all([
            cpuModule(),
            memoryModule(),
            diskModule("/", "/media/sf_Downloads"),
            netModule(),
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
