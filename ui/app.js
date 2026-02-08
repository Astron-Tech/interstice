const output = document.getElementById("output");

async function run(command) {
  output.textContent = "Running…";

  try {
    const res = await fetch("http://localhost:9999/run", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ command })
    });

    const data = await res.json();

    if (!res.ok) {
      output.textContent = data.error || "Error";
      return;
    }

    output.textContent =
      (data.stdout || "") +
      (data.stderr ? "\n" + data.stderr : "");
  } catch (err) {
    output.textContent = "API unreachable";
  }
}
