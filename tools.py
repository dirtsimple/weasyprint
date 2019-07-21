from urllib.parse import parse_qs
from weasyprint import HTML
from flask import Flask, request, make_response

prod = Flask('prod')

@prod.route('/health')
def ok():
    return 'ok'

@prod.route('/pdf', methods=['POST'])
def gen_pdf():
    name = request.args.get('filename', 'unnamed.pdf')
    response = make_response( HTML(string=request.data).write_pdf() )
    response.headers['Content-Type'] = 'application/pdf'
    response.headers['Content-Disposition'] = 'inline;filename=%s' % name
    return response

# dev tools
def dev(env, sr):
    path = env['PATH_INFO']
    args = parse_qs(env.get('QUERY_STRING') or '')

    if 'url' in args or path.startswith('/pdf/') or path.startswith('/view/'):
        from weasyprint.tools.navigator import app as nav_app
        return nav_app(env, sr)

    if path == '/pdf' or path == '/health':
        return prod(env, sr)

    from weasyprint.tools.renderer import app as render_app
    return render_app(env, sr)

