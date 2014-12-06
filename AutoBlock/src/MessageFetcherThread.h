#ifndef MESSAGEFETCHERTHREAD_H_
#define MESSAGEFETCHERTHREAD_H_

#include <QObject>
#include <QRunnable>
#include <QVariant>

namespace autoblock {

class MessageFetcherThread : public QObject, public QRunnable
{
	Q_OBJECT

	QByteArray m_data;

signals:
	void messageFetched(QVariantMap const& m);

public:
	MessageFetcherThread(QByteArray const& data, QObject* parent=NULL);
	virtual ~MessageFetcherThread();

	void run();
};

} /* namespace canadainc */
#endif /* MessageFetcherThread_H_ */
