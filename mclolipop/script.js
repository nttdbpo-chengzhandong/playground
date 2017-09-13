import { check } from "k6";
import http from "k6/http";

export let options = {
  vus: 10,
  duration: "120s"
};

export default function() {
    let res = http.get("https://101000lab.lolipop.io/bench.php");
    check(res, {
        "status was 200": (r) => r.status == 200,
        "transaction time OK (< 5000ms) ": (r) => r.timings.duration < 5000
    });
};
