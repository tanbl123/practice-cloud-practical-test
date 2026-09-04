"""Shared grading helper for the practice labs."""
import sys, boto3, botocore

ENDPOINT = "http://127.0.0.1:5000"
REGION = "us-east-1"

def client(service):
    return boto3.client(service, endpoint_url=ENDPOINT, region_name=REGION,
                        aws_access_key_id="test", aws_secret_access_key="test")

GREEN, RED, YELLOW, DIM, BOLD, RESET = "\033[32m", "\033[31m", "\033[33m", "\033[2m", "\033[1m", "\033[0m"

class Grader:
    def __init__(self, title):
        self.title = title
        self.results = []
        print(f"\n{BOLD}Grading: {title}{RESET}\n" + "-" * 62)

    def check(self, marks, description, fn, hint=""):
        """fn() -> True/False, or raises. Awards `marks` on True."""
        try:
            ok = bool(fn())
            err = ""
        except botocore.exceptions.ClientError as e:
            ok, err = False, e.response["Error"]["Code"]
        except Exception as e:
            ok, err = False, f"{type(e).__name__}: {e}"
        mark = f"{GREEN}PASS{RESET}" if ok else f"{RED}FAIL{RESET}"
        print(f"[{mark}] ({marks:>2} marks) {description}")
        if not ok:
            if err:
                print(f"         {DIM}error: {err}{RESET}")
            if hint:
                print(f"         {YELLOW}hint: {hint}{RESET}")
        self.results.append((marks if ok else 0, marks))
        return ok

    def report(self):
        got = sum(r[0] for r in self.results)
        total = sum(r[1] for r in self.results)
        pct = (got / total * 100) if total else 0
        print("-" * 62)
        colour = GREEN if pct >= 80 else (YELLOW if pct >= 50 else RED)
        print(f"{BOLD}Score: {colour}{got}/{total}  ({pct:.0f}%){RESET}")
        if pct == 100:
            print(f"{GREEN}All requirements met. Move on to the next lab.{RESET}\n")
        elif pct >= 50:
            print(f"{YELLOW}Partly done — fix the FAIL lines above and re-run.{RESET}\n")
        else:
            print(f"{RED}Re-read TASK.md and try again. `cat solution.sh` only as a last resort.{RESET}\n")
        sys.exit(0 if got == total else 1)
