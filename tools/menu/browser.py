from .common import Command, Mode

DISPLAY_PREFIX = "browser"

PERSONAL_PROFILE = "Default"
WORK_PROFILE = "Profile 4"


PERSONAL = {
    "hackernews": "https://news.ycombinator.com/",
    "asoftmurmur": "https://asoftmurmur.com/",
    "chatgpt": "https://chatgpt.com/",
    "claude": "https://claude.ai/",
    "gemini": "https://gemini.google.com/",
    "github": "https://github.com/",
    "whatsapp": "https://web.whatsapp.com/",
    "gmail": {
        "url": "https://mail.google.com/",
        "show_profile": True,
    },
    "calendar": {
        "url": "https://calendar.google.com/",
        "show_profile": True,
    },
}

WORK = {
    "gmail": {
        "url": "https://mail.google.com/",
        "show_profile": True,
    },
    "calendar": {
        "url": "https://calendar.google.com/",
        "show_profile": True,
    },
}


def browser_commands(entries, profile, qualifier):
    commands = {}

    for name, value in entries.items():
        if isinstance(value, str):
            url = value
            key = name
        else:
            url = value["url"]
            key = f"{qualifier} {name}" if value.get("show_profile") else name

        commands[key] = Command(
            [
                "google-chrome",
                f"--profile-directory={profile}",
                url,
            ],
            mode=Mode.DETACHED,
            display_prefix=True,
        )

    return commands


COMMANDS = {
    **browser_commands(
        PERSONAL,
        PERSONAL_PROFILE,
        "personal",
    ),
    **browser_commands(
        WORK,
        WORK_PROFILE,
        "work",
    ),
}


def candidates():
    result = []

    for key, command in COMMANDS.items():
        if command.display_prefix:
            result.append(f"{DISPLAY_PREFIX} {key}")
        else:
            result.append(key)

    return result


def resolve(name):
    prefix = f"{DISPLAY_PREFIX} "

    name = name.removeprefix(prefix)

    return COMMANDS.get(name)
